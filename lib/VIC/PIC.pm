package VIC::PIC;
use strict;
use warnings;
use bigint;
use POSIX ();

our $VERSION = '0.04';
$VERSION = eval $VERSION;

use Pegex::Base;
extends 'Pegex::Tree';

use VIC::PIC::Any;
#use XXX;

has pic_override => undef;
has pic => undef;
has ast => {
    block_stack => [],
    block_stack_top => 0,
    funcs => {},
    variables => {},
    tmp_variables => {},
    conditionals => 0,
};
has intermediate_inline => undef;

sub stack { reverse @{shift->parser->stack}; }

sub got_uc_select {
    my ($self, $type) = @_;
    # override the PIC in code if defined
    $type = $self->pic_override if defined $self->pic_override;
    $type = lc $type;
    # assume supported type else return
    $self->pic(VIC::PIC::Any->new($type));
    die "$type is not a supported chip" unless $self->pic->type eq $type;
    $self->ast->{include} = $self->pic->include;
    # set the defaults in case the headers are not provided by the user
    $self->ast->{org} = $self->pic->org;
    $self->ast->{config} = $self->pic->config;
    return;
}

sub got_uc_config {
    my ($self, $list) = @_;
    $self->flatten($list);
    $self->pic->update_config(@$list);
    # get the updated config
    $self->ast->{config} = $self->pic->config;
    return;
}

sub got_block {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $block = shift @$list;
    my $parent = shift @$list;
    if (exists $self->ast->{$block} and ref $self->ast->{$block} eq 'ARRAY') {
        my $block_label = $self->ast->{$block}->[0];
        ## this expression is dependent on got_start_block()
        my ($tag, $label) = split /::/, $block_label;
        $block_label = "BLOCK::${label}::${block}" if $label;
        ## do not allow the parent to be a label
        if (defined $parent) {
            unless ($parent =~ /BLOCK::/) {
                $block_label .= "::$parent";
                if (exists $self->ast->{$parent} and
                    ref $self->ast->{$parent} eq 'ARRAY' and
                    $parent ne $block) {
                    my $plabel = $1 if $self->ast->{$parent}->[0] =~ /^\s*(\w+):/;
                    $block_label .= "::$plabel" if $plabel;
                }
            }
            my $ccount = $self->ast->{conditionals};
            $block_label .= "::_end_conditional_$ccount" if $block_label =~ /True|False/i;
            $block_label .= "::_end$label" if $block_label !~ /True|False/i;
            push @{$self->ast->{$parent}}, $block_label;
        }
        return $block_label;
    }
}

sub got_start_block {
    my ($self, $list) = @_;
    $self->flatten($list); # we flatten because we only want the name out
    my $block = shift @$list;
    my $id = $self->ast->{block_stack_top};
    $block = "$block$id" if $block =~ /^(?:Loop|Action|True|False)/;
    push @{$self->ast->{block_stack}}, $block;
    $self->ast->{block_stack_top} = scalar @{$self->ast->{block_stack}};
    my $stack = [];
    if ($block eq 'Main') {
        push @$stack, "LABEL::_start";
    } elsif ($block =~ /^Loop/) {
        push @$stack, "LABEL::_loop_${id}";
    } elsif ($block =~ /^Action/) {
        push @$stack, "LABEL::_action_${id}";
    } elsif ($block =~ /^True/) {
        push @$stack, "LABEL::_true_${id}";
    } elsif ($block =~ /^False/) {
        push @$stack, "LABEL::_false_${id}";
    } elsif ($block =~ /^ISR/) {
        push @$stack, "LABEL::_isr_${id}";
    } else {
        my $lcb = lc "_$block";
        push @$stack, "LABEL::$lcb";
    }
    $self->ast->{$block} = $stack;
    return $block;
}

sub got_end_block {
    my ($self, $list) = @_;
    # we are not capturing anything here
    my $block = pop @{$self->ast->{block_stack}};
    $self->ast->{block_stack_top} = scalar @{$self->ast->{block_stack}};
    my $top = $self->ast->{block_stack_top};
    return $block if $top eq 0;
    return $self->ast->{block_stack}->[$top - 1];
}

sub got_name {
    my ($self, $list) = @_;
    if (ref $list eq 'ARRAY') {
        $self->flatten($list);
        return shift(@$list);
    } else {
        return $list;
    }
}

sub update_intermediate {
    my $self = shift;
    my $top = $self->ast->{block_stack_top};
    $top = $top - 1 if $top > 0;
    my $block = $self->ast->{block_stack}->[$top];
    push @{$self->ast->{$block}}, @_ if $block;
    return;
}

sub got_instruction {
    my ($self, $list) = @_;
    my $method = shift @$list;
    $self->flatten($list) if $list;
    return $self->parser->throw_error("Unknown instruction '$method'") unless $self->pic->can($method);
    my @args = ();
    while (scalar @$list) {
        my $a = shift @$list;
        if ($a =~ /BLOCK::(\w+)::Action\w+::.*::(_end_\w+)$/) {
            push @args, "ACTION::$1::END::$2";
        } elsif ($a =~ /BLOCK::(\w+)::ISR::.*::(_end_\w+)$/) {
            push @args, "ISR::$1::END::$2";
        } else {
            push @args, $a;
        }
    }
    $self->update_intermediate("INS::${method}::" . join ("::", @args));
    return;
}

sub got_unary_expr {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $op = shift @$list;
    my $varname = shift @$list;
    $self->update_intermediate("UNARY::${op}::${varname}");
    return;
}

sub got_assign_expr {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $varname = shift @$list;
    my $op = shift @$list;
    my $rhsx = $self->got_expr_value($list);
    my $rhs = ref $rhsx eq 'ARRAY' ? join ("::", @$rhsx) : $rhsx;
    $self->update_intermediate("SET::${op}::${varname}::${rhs}");
    return;
}

sub got_conditional {
    my ($self, $list) = @_;
    my ($subject, $predicate) = @$list;
    $self->flatten($predicate);
    return unless scalar @$predicate;
    #YYY $self->stack;
    #TODO: handle complex-conditionals using temp vars
    $self->flatten($subject);
    my ($lhs, $op, $rhs) = @$subject;
    $self->update_intermediate("COND::${op}::${lhs}::${rhs}");
    if (ref $predicate ne 'ARRAY') {
        $predicate = [ $predicate ];
    }
    my ($false_label, $true_label, $end_label);
    #TODO: handle if-elsif cases also
    foreach my $p (@$predicate) {
        $false_label = $1 if $p =~ /BLOCK::(\w+)::False/;
        $true_label = $1 if $p =~ /BLOCK::(\w+)::True/;
        $end_label = $1 if $p =~ /BLOCK::.*::(_end_conditional\w+)$/;
    }
    $self->update_intermediate("COND1::FALSE::${false_label}::TRUE::${true_label}::END::${end_label}");
    $self->ast->{conditionals}++;
    return;
    #TODO: remove
    #my $method = $self->pic->validate_modifier($op);
    #return $self->parser->throw_error("Unknown method '$method'") unless $self->pic->can($method);
    #my $ccount = $self->ast->{conditionals};
    #my ($code, $funcs, $macros) = $self->pic->$method($lhs, $rhs, $predicate, $ccount);
    #$self->parser->throw_error("Unable to generate code for comparison expression"), return unless $code;
    #$self->_update_block($code, $funcs, $macros);
    #$self->ast->{conditionals}++;
    #return;
}

##WARNING: do not change this function without looking at its effect on
#got_assign_expr() above which calls this function explicitly
sub got_expr_value {
    my ($self, $list) = @_;
    if (ref $list eq 'ARRAY') {
        $self->flatten($list);
        if (scalar @$list == 1) {
            return shift @$list;
        } elsif (scalar @$list == 2) {
            my ($op, $varname) = @$list;
            my $vref = $self->ast->{tmp_variables};
            my $tvar = '_vic_tmp_' . scalar(keys %$vref);
            $vref->{$tvar} = "OP::${tvar}::${op}::${varname}";
            $self->update_intermediate($vref->{$tvar});
            return $tvar;
        } else {
            # TODO: handle precedence
            while (scalar @$list >= 3) {
                # using Quadruples method as per Dragon book Chapter 8 Page 470
                my $var1 = shift @$list;
                my $op = shift @$list;
                my $var2 = shift @$list;
                my $vref = $self->ast->{tmp_variables};
                my $tvar = '_vic_tmp_' . scalar(keys %$vref);
                $vref->{$tvar} = "OP::${tvar}::${op}::${var1}::${var2}";
                $self->update_intermediate($vref->{$tvar});
                unshift @$list, $tvar;
            }
#            YYY $self->ast->{tmp_variables};
#            YYY $list;
            return $list;
        }
    } else {
        return $list;
    }
}

sub got_math_operator {
    my ($self, $op) = @_;
    return 'ADD' if $op eq '+';
    return 'SUB' if $op eq '-';
    return 'MUL' if $op eq '*';
    return 'DIV' if $op eq '/';
    return 'MOD' if $op eq '%';
    return $self->parser->throw_error("Math operator '$op' is not supported");
}

sub got_bit_operator {
    my ($self, $op) = @_;
    return 'BXOR' if $op eq '^';
    return 'BOR'  if $op eq '|';
    return 'BAND' if $op eq '&';
    return $self->parser->throw_error("Bitwise operator '$op' is not supported");
}

sub got_logic_operator {
    my ($self, $op) = @_;
    return 'AND' if $op eq '&&';
    return 'OR' if $op eq '||';
    return $self->parser->throw_error("Logic operator '$op' is not supported");
}

sub got_compare_operator {
    my ($self, $op) = @_;
    return 'LE' if $op eq '<=';
    return 'LT' if $op eq '<';
    return 'GE' if $op eq '>=';
    return 'GT' if $op eq '>';
    return 'EQ' if $op eq '==';
    return 'NE' if $op eq '!=';
    return $self->parser->throw_error("Compare operator '$op' is not supported");
}

sub got_complement_operator {
    my ($self, $op) = @_;
    return 'NOT'  if $op eq '!';
    return 'COMP' if $op eq '~';
    return $self->parser->throw_error("Complement operator '$op' is not supported");
}

sub got_assign_operator {
    my ($self, $op) = @_;
    return 'ASSIGN' if $op eq '=';
    return 'ADD_ASSIGN'  if $op eq '+=';
    return 'SUB_ASSIGN'  if $op eq '-=';
    return 'MUL_ASSIGN'  if $op eq '*=';
    return 'DIV_ASSIGN'  if $op eq '/=';
    return 'MOD_ASSIGN'  if $op eq '%=';
    return 'BXOR_ASSIGN' if $op eq '^=';
    return 'BOR_ASSIGN'  if $op eq '|=';
    return 'BAND_ASSIGN' if $op eq '&=';
    return $self->parser->throw_error("Assignment operator '$op' is not supported");
}

sub got_unary_operator {
    my ($self, $op) = @_;
    return 'INC' if $op eq '++';
    return 'DEC' if $op eq '--';
    return $self->parser->throw_error("Increment/Decrement operator '$op' is not supported");
}

sub got_modifier_variable {
    my ($self, $list) = @_;
    my ($modifier, $varname);
    $self->flatten($list) if ref $list eq 'ARRAY';
    $modifier = shift @$list;
    $varname = shift @$list;
    $self->parser->throw_error("Modifying operator '$modifier' not supported") unless
        $self->pic->validate_modifier($modifier);
    $modifier = uc $modifier;
    #TODO: figure out a better way
    return "MOP::$modifier\::$varname";
}

sub got_validated_variable {
    my ($self, $list) = @_;
    my $varname;
    if (ref $list eq 'ARRAY') {
        $self->flatten($list);
        $varname = shift @$list;
    } else {
        $varname = $list;
    }
    return $varname if $self->pic->validate($varname);
    return $self->parser->throw_error("'$varname' is not a valid part of the " . uc $self->pic->type);
    return;
}

sub got_variable {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $varname = shift @$list;
    my ($current, $parent) = $self->stack;
    # if the variable is used from the uc-config grammar rule
    # we do not want to store it yet and definitely not store the size yet
    # we could remove this if we set the size after the code generation or so
    # but that may lead to more complexity. this is much easier
    return $varname if $parent eq 'uc_config';
    $self->ast->{variables}->{$varname} = {
        name => uc $varname,
        scope => $self->ast->{block_stack_top},
        size => POSIX::ceil($self->pic->address_bits($varname) / 8),
    } unless exists $self->ast->{variables}->{$varname};
    return $varname;
}

sub got_number {
    my ($self, $list) = @_;
    # if it is a hexadecimal number we can just convert it to number using int()
    # since hex is returned here as a string
    return hex($list) if $list =~ /0x|0X/;
    return int($list);
}

# convert the number to appropriate units
sub got_number_units {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $num = shift @$list;
    my $units = shift @$list;
    return $num unless defined $units;
    $num *= 1 if $units eq 'us';
    $num *= 1000 if $units eq 'ms';
    $num *= 1e6 if $units eq 's';
    $num *= 1 if $units eq 'Hz';
    $num *= 1000 if $units eq 'kHz';
    $num *= 1e6 if $units eq 'MHz';
    return $num;
}

# remove the dumb stuff from the tree
sub got_comment { return; }

sub _update_funcs {
    my ($self, $funcs, $macros) = @_;
    if (ref $funcs eq 'HASH') {
        foreach (keys %$funcs) {
            $self->ast->{funcs}->{$_} = $funcs->{$_};
        }
    }
    if (ref $macros eq 'HASH') {
        return unless ref $macros eq 'HASH';
        foreach (keys %$macros) {
            $self->ast->{macros}->{$_} = $macros->{$_};
        }
    }
    1;
}

sub generate_code_instruction {
    my ($self, $line) = @_;
    my @ins = split /::/, $line;
    shift @ins; # remove INS
    my $method = shift @ins;
    my ($code, $funcs, $macros) = $self->pic->$method(@ins);
    return $self->parser->throw_error("Error in intermediate code '$line'") unless $code;
    my @code = ();
    push @code, "\t;; $line" if $self->intermediate_inline;
    push @code, $code if $code;
    $self->_update_funcs($funcs, $macros) if ($funcs or $macros);
    return @code;
}

sub generate_code_unary_expr {
    my ($self, $line) = @_;
    my @code = ();
    my $ast = $self->ast;
    my ($tag, $op, $varname) = split /::/, $line;
    my $method = $self->pic->validate_operator($op);
    $self->parser->throw_error("Invalid operator '$op' in intermediate code") unless $self->pic->can($method);
    # check if temporary variable or not
    if (exists $ast->{variables}->{$varname}) {
        my $nvar = $ast->{variables}->{$varname}->{name} || uc $varname;
        my ($code, $funcs, $macros) = $self->pic->$method($nvar);
        return $self->parser->throw_error("Error in intermediate code '$line'") unless $code;
        push @code, "\t;; $line" if $self->intermediate_inline;
        push @code, $code if $code;
        $self->_update_funcs($funcs, $macros) if ($funcs or $macros);
    } elsif (exists $ast->{tmp_variables}->{$varname}) {
        #TODO: check if the tmp-var address bits works correctly
        my $tmp_code = $ast->{tmp_variables}->{$varname};
        my @newcode = $self->generate_code($ast, $tmp_code);
        push @code, "\t;; $varname = $tmp_code\n" if $self->intermediate_inline;
        push @code, @newcode if @newcode;
        push @code, "\t;; $line" if $self->intermediate_inline;
        #TODO: how do we move the tmp-var code into the actual var
    }
    return @code;
}

sub generate_code_operations {
    my ($self, $line) = @_;
    my @code = ();
    my $ast = $self->ast;
    my ($tag, $tvar, $op, $var1, $var2) = split /::/, $line;
    my $method = $self->pic->validate_operator($op);
    $self->parser->throw_error("Invalid operator '$op' in intermediate code") unless $self->pic->can($method);
    push @code, "\t;; $line" if $self->intermediate_inline;
    if (defined $var2) {
        push @code, "\t;; $tvar = $var1 $op $var2" if $self->intermediate_inline;
        $var2 = uc $var2;
    } else {
        push @code, "\t;; $tvar = $op $var1" if $self->intermediate_inline;
    }
    $var1 = uc $var1;
    my ($code, $funcs, $macros) = $self->pic->$method($var1, $var2);
    return $self->parser->throw_error("Error in intermediate code '$line'") unless $code;
    push @code, $code if $code;
    $self->_update_funcs($funcs, $macros) if ($funcs or $macros);
    return @code;
}

sub generate_code_assign_expr {
    my ($self, $line) = @_;
    my @code = ();
    my $ast = $self->ast;
    my ($tag, $op, $varname, $rhs) = split /::/, $line;
    if (exists $ast->{variables}->{$varname}) {
        my $suffix = '';
        $suffix = '_literal' if $rhs =~ /^\d+$/;
        $suffix = '_variable' if exists $ast->{variables}->{$rhs};
        if (exists $ast->{tmp_variables}->{$rhs}) {
            my $tmp_code = $ast->{tmp_variables}->{$rhs};
            $suffix = '_variable' if exists $ast->{tmp_variables}->{$rhs};
            push @code, "\t;; $rhs = $tmp_code\n";
            #TODO: check if the tmp-var address bits works correctly
            my @newcode = $self->generate_code($ast, $tmp_code);
            push @code, @newcode if @newcode;
            #TODO: how do we move the tmp-var code into the actual var
        }
        my $method = $self->pic->validate_operator($op);
        $method .= $suffix if $method;
        $self->parser->throw_error("Invalid operator '$op' in intermediate code") unless $self->pic->can($method);
        my $nvar = $ast->{variables}->{$varname}->{name} || uc $varname;
        my ($code, $funcs, $macros) = $self->pic->$method($nvar, $rhs);
        return $self->parser->throw_error("Error in intermediate code '$line'") unless $code;
        push @code, "\t;; $line" if $self->intermediate_inline;
        push @code, $code if $code;
        $self->_update_funcs($funcs, $macros) if ($funcs or $macros);
    } elsif (exists $ast->{tmp_variables}->{$varname}) {
        #TODO: check if the tmp-var address bits works correctly
        my $tmp_code = $ast->{tmp_variables}->{$varname};
        my @newcode = $self->generate_code($ast, $tmp_code);
        push @code, "\t;; $varname = $tmp_code\n" if $self->intermediate_inline;
        push @code, @newcode if @newcode;
        push @code, "\t;; $line" if $self->intermediate_inline;
        #TODO: how do we move the tmp-var code into the actual var
    } else {
        return $self->parser->throw_error("Error in intermediate code '$line'");
    }
    return @code;
}

sub generate_code_blocks {
    my ($self, $line, $block) = @_;
    my @code = ();
    my $ast = $self->ast;
    my ($tag, $label, $child, $parent, $parent_label, $end_label) = split/::/, $line;
    return if $child eq $parent; # bug - FIXME
    return if $child eq $block; # bug - FIXME
    return if exists $ast->{generated_blocks}->{$child};
    push @code, "\t;; $line" if $self->intermediate_inline;
    my @newcode = $self->generate_code($ast, $child);
    if ($child =~ /^Action|True|False|ISR/) {
        push @newcode, "\tgoto $end_label;; go back to end of conditional\n" if @newcode;
        # hack into the function list
        $ast->{funcs}->{$label} = [@newcode] if @newcode;
    } else {
        push @code, @newcode if @newcode;
    }
    $ast->{generated_blocks}->{$child} = 1 if @newcode;
    # parent equals block if it is the topmost of the stack
    # if the child is not a loop construct it will need a goto back to
    # the parent construct. if a child is a loop construct it will
    # already have a goto back to itself
    if (defined $parent and exists $ast->{$parent} and
        ref $ast->{$parent} eq 'ARRAY' and $parent ne $block) {
        my $plabel = $1 if $ast->{$parent}->[0] =~ /^\s*(\w+):/;
        push @code, "\tgoto $plabel;; $plabel" if $plabel;
    }
    push @code, "\tgoto $label" if $child =~ /^Loop/;
    return @code;
}

sub generate_code {
    my ($self, $ast, $block_name) = @_;
    my @code = ();
    return wantarray ? @code : [] unless defined $ast;
    return wantarray ? @code : [] unless exists $ast->{$block_name};
    $ast->{generated_blocks} = {} unless defined $ast->{generated_blocks};
    push @code, ";;;; generated code for $block_name";
    my $blocks = $ast->{$block_name};
    while (@$blocks) {
        my $line = shift @$blocks;
        if ($line =~ /^BLOCK::\w+/) {
            push @code, $self->generate_code_blocks($line, $block_name);
        } elsif ($line =~ /^INS::\w+/) {
            push @code, $self->generate_code_instruction($line);
        } elsif ($line =~ /^UNARY::\w+/) {
            push @code, $self->generate_code_unary_expr($line);
        } elsif ($line =~ /^SET::\w+/) {
            push @code, $self->generate_code_assign_expr($line);
        } elsif ($line =~ /^OP::\w+/) {
            push @code, $self->generate_code_operations($line);
        } elsif ($line =~ /^LABEL::(\w+)/) {
            push @code, ";; $line" if $self->intermediate_inline;
            push @code, "$1:\n"; # label name
        } elsif ($line =~ /^COND::/) {
            push @code, $line;
            while ($blocks->[0] =~ /^COND\d::/) {
                my $condline = shift @$blocks;
                push @code, $condline;
            }
        } else {
            #push @code, $line; # other things
            $self->parser->throw_error("Intermediate code '$line' cannot be handled");
        }
    }
    return wantarray ? @code : [@code];
}

sub final {
    my ($self, $got) = @_;
    my $ast = $self->ast;
    return $self->parser->throw_error("Missing '}'") if $ast->{block_stack_top} ne 0;
    return $self->parser->throw_error("Main not defined") unless defined $ast->{Main};
    # generate main code first so that any addition to functions, macros,
    # variables during generation can be handled after
    my @main_code = $self->generate_code($ast, 'Main');
    my $main_code = join("\n", @main_code);
    # variables are part of macros and need to go first
    my $variables = '';
    my $vhref = $ast->{variables};
    $variables .= "GLOBAL_VAR_UDATA udata\n" if keys %$vhref;
    foreach my $var (sort(keys %$vhref)) {
        # should we care about scope ?
        # FIXME: initialized variables ?
        $variables .= "$vhref->{$var}->{name} res $vhref->{$var}->{size}\n";
    }
    my $macros = '';
    foreach my $mac (sort(keys %{$ast->{macros}})) {
        $variables .= "\n" . $ast->{macros}->{$mac} . "\n", next if $mac =~ /_var$/;
        $macros .= $ast->{macros}->{$mac};
        $macros .= "\n";
    }
    my $isr_checks = '';
    my $isr_code = '';
    my $funcs = '';
    foreach my $fn (sort(keys %{$ast->{funcs}})) {
        my $fn_val = $ast->{funcs}->{$fn};
        # the default ISR checks to be done first
        if ($fn =~ /^isr_\w+$/) {
            if (ref $fn_val eq 'ARRAY') {
                $isr_checks .= join("\n", @$fn_val);
            } else {
                $isr_checks .= $fn_val . "\n";
            }
        # the user ISR code to be handled next
        } elsif ($fn =~ /^_isr_\w+$/) {
            if (ref $fn_val eq 'ARRAY') {
                $isr_code .= join("\n", @$fn_val);
            } else {
                $isr_code .= $fn_val . "\n";
            }
        } else {
            if (ref $fn_val eq 'ARRAY') {
                $funcs .= join("\n", @$fn_val);
            } else {
                $funcs .= "$fn:\n";
                $funcs .= $fn_val unless ref $fn_val eq 'ARRAY';
            }
            $funcs .= "\n";
        }
    }
    if (length $isr_code) {
        my $isr_entry = $self->pic->isr_entry;
        my $isr_exit = $self->pic->isr_exit;
        my $isr_var = $self->pic->isr_var;
        $isr_checks .= "\tgoto _isr_exit\n";
        $isr_code = "\tgoto _start\n$isr_entry\n$isr_checks\n$isr_code\n$isr_exit\n";
        $variables .= "\n$isr_var\n";
    }
    my $pic = <<"...";
;;;; generated code for PIC header file
#include <$ast->{include}>

;;;; generated code for variables
$variables
;;;; generated code for macros
$macros

$ast->{config}

\torg $ast->{org}

$isr_code

$main_code

;;;; generated code for functions
$funcs

;;;; generated code for end-of-file
\tend
...
    return $pic;
}

1;

=encoding utf8

=head1 NAME

VIC::PIC

=head1 SYNOPSIS

The Pegex::Receiver class for handling the grammar.

=head1 DESCRIPTION

INTERNAL CLASS.

=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
