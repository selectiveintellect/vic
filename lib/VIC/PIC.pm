package VIC::PIC;
use strict;
use warnings;
use bigint;
use POSIX ();
use List::Util qw(max);

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
    block_mapping => {},
    block_count => 0,
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

sub handle_named_block {
    my ($self, $name, $anon_block, $parent) = @_;
    my $id = $1 if $anon_block =~ /_anonblock(\d+)/;
    $id = $self->ast->{block_count} unless defined $id;
    my $expected_label;
    if ($name eq 'Main') {
        $expected_label = "_start";
    } elsif ($name =~ /^Loop/) {
        $expected_label = "_loop_${id}";
    } elsif ($name =~ /^Action/) {
        $expected_label = "_action_${id}";
    } elsif ($name =~ /^True/) {
        $expected_label = "_true_${id}";
    } elsif ($name =~ /^False/) {
        $expected_label = "_false_${id}";
    } elsif ($name =~ /^ISR/) {
        $expected_label = "_isr_${id}";
    } else {
        $expected_label = lc "_$name$id";
    }
    $name .= $id if $name =~ /^(?:Loop|Action|True|False|ISR)/;
    $self->ast->{block_mapping}->{$name} = {
        label => $expected_label,
        block => $anon_block,
    };
    $self->ast->{block_mapping}->{$anon_block} = {
        label => $expected_label,
        block => $name,
    };
    # make sure the anon-block and named-block refer to the same block
    $self->ast->{$name} = $self->ast->{$anon_block};

    my $stack = $self->ast->{$name} || $self->ast->{$anon_block};
    if (defined $stack and ref $stack eq 'ARRAY') {
        my $block_label = $stack->[0];
        ## this expression is dependent on got_start_block()
        my ($tag, $label, @others) = split /::/, $block_label;
        $label = $expected_label if $label ne $expected_label;
        $block_label = "BLOCK::${label}::${name}" if $label;
        # change the LABEL:: value in the stack for code-generation ease
        # we want to use the expected label and not the anon one unless it is an
        # anon-block
        $stack->[0] = join("::", $tag, $label, @others);
        ## do not allow the parent to be a label
        if (defined $parent) {
            unless ($parent =~ /BLOCK::/) {
                $block_label .= "::$parent";
                if (exists $self->ast->{$parent} and
                    ref $self->ast->{$parent} eq 'ARRAY' and
                    $parent ne $anon_block) {
                    my ($ptag, $plabel) = split /::/, $self->ast->{$parent}->[0];
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

sub got_named_block {
    my ($self, $list) = @_;
    $self->flatten($list) if ref $list eq 'ARRAY';
    my ($name, $anon_block, $parent_block) = @$list;
    return $self->handle_named_block(@$list);
}

sub got_anonymous_block {
    my $self = shift;
    my $list = shift;
    $self->flatten($list);
    # returns anon_block and parent_block
    return $list;
}

sub got_start_block {
    my ($self, $list) = @_;
    my $id = $self->ast->{block_count};
    # we may not know the block name here
    my $block = lc "_anonblock$id";
    push @{$self->ast->{block_stack}}, $block;
    $self->ast->{$block} = [ "LABEL::$block" ];
    $self->ast->{block_count}++;
    return $block;
}

sub got_end_block {
    my ($self, $list) = @_;
    # we are not capturing anything here
    my $block = pop @{$self->ast->{block_stack}};
    return $self->ast->{block_stack}->[-1];
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
    my $block = $self->ast->{block_stack}->[-1];
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
        } elsif ($a =~ /BLOCK::(\w+)::ISR\w+::.*::(_end_\w+)$/) {
            push @args, "ISR::$1::END::$2";
        } else {
            push @args, $a;
        }
    }
    $self->update_intermediate("INS::${method}::" . join ("::", @args));
    return;
}

sub got_unary_rhs {
    my ($self, $list) = @_;
    $self->flatten($list);
    return [ reverse @$list ];
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

sub got_conditional_statement {
    my ($self, $list) = @_;
    my ($subject, $predicate) = @$list;
    return unless scalar @$predicate;
    my ($current, $parent) = $self->stack;
    my $subcond = 0;
    $subcond = 1 if $parent =~ /^conditional/;
    if (ref $predicate ne 'ARRAY') {
        $predicate = [ $predicate ];
    }
    my @condblocks = ();
    if (scalar @$predicate < 3) {
        my $tb = $predicate->[0] || undef;
        my $fb = $predicate->[1] || undef;
        $self->flatten($tb) if $tb;
        $self->flatten($fb) if $fb;
        my $true_block = $self->handle_named_block('True', @$tb) if $tb and scalar @$tb;
        push @condblocks, $true_block if $true_block;
        my $false_block = $self->handle_named_block('False', @$fb)  if $fb and scalar @$fb;
        push @condblocks, $false_block if $false_block;
    } else {
        return $self->parser->throw_error("Multiple predicate conditionals not implemented");
    }
    my $inter;
    if (scalar @condblocks < 3) {
        my ($false_label, $true_label, $end_label);
        foreach my $p (@condblocks) {
            $false_label = $1 if $p =~ /BLOCK::(\w+)::False\d+::/;
            $true_label = $1 if $p =~ /BLOCK::(\w+)::True\d+::/;
            $end_label = $1 if $p =~ /BLOCK::.*::(_end_conditional\w+)$/;
        }
        $false_label = $end_label unless defined $false_label;
        $true_label = $end_label unless defined $true_label;
        my $subj = $subject;
        $subj = shift @$subject if ref $subject eq 'ARRAY';
        $inter = join("::",
                COND => $self->ast->{conditionals},
                SUBJ => $subj,
                FALSE => $false_label,
                TRUE => $true_label,
                END => $end_label);
    } else {
        return $self->parser->throw_error("Multiple predicate conditionals not implemented");
    }
    $self->update_intermediate($inter);
    $self->ast->{conditionals}++ unless $subcond;
    return;
}

##WARNING: do not change this function without looking at its effect on
#got_conditional_statement() above which calls this function explicitly
# this function is identical to got_expr_value() and hence redundant
# we may need to just use the same one although precedence will be different
# so maybe not
sub got_conditional_subject {
    my ($self, $list) = @_;
    #TODO: handle complex-conditionals using temp vars
    if (ref $list eq 'ARRAY') {
        $self->flatten($list);
        if (scalar @$list == 1) {
            return shift @$list;
        } elsif (scalar @$list == 2) {
            my ($op, $var) = @$list;
            my $vref = $self->ast->{tmp_variables};
            my $tvar = '_vic_tmp_' . scalar(keys %$vref);
            $vref->{$tvar} = "OP::${op}::${var}";
            return $tvar;
        } else {
            # TODO: handle precedence
            while (scalar @$list >= 3) {
                my $var1 = shift @$list;
                my $op = shift @$list;
                my $var2 = shift @$list;
                my $vref = $self->ast->{tmp_variables};
                my $tvar = '_vic_tmp_' . scalar(keys %$vref);
                $vref->{$tvar} = "OP::${var1}::${op}::${var2}";
                $vref->{$tvar} = "OP::${var1}::${op}::${var2}";
                unshift @$list, $tvar;
            }
            return $list;
        }
    } else {
        return $list;
    }
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
            my ($op, $var) = @$list;
            my $vref = $self->ast->{tmp_variables};
            my $tvar = '_vic_tmp_' . scalar(keys %$vref);
            $vref->{$tvar} = "OP::${op}::${var}";
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
                $vref->{$tvar} = "OP::${var1}::${op}::${var2}";
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
    #return $self->parser->throw_error("'$varname' is not a valid part of the " . uc $self->pic->type);
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
        scope => $self->ast->{block_stack}->[-1],
        size => POSIX::ceil($self->pic->address_bits($varname) / 8),
    } unless exists $self->ast->{variables}->{$varname};
    return $varname;
}

sub got_boolean {
    my ($self, $list) = @_;
    my $b;
    if (ref $list eq 'ARRAY') {
        $self->flatten($list);
        $b = shift @$list;
    } else {
        $b = $list;
    }
    return 1 if $b =~ /TRUE|true/i;
    return 1 if $b == 1;
    return 0 if $b =~ /FALSE|false/i;
    return 0; # default boolean is false
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
    my $tag = shift @ins;
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
    } else {
        return $self->parser->throw_error("Error in intermediate code '$line'");
    }
    return @code;
}

sub generate_code_operations {
    my ($self, $line, %extra) = @_;
    my @code = ();
    my ($tag, @args) = split /::/, $line;
    my ($op, $var1, $var2);
    if (scalar @args == 2) {
        $op = shift @args;
        $var1 = shift @args;
        $var1 = uc $var1;
    } elsif (scalar @args == 3) {
        $var1 = shift @args;
        $var1 = uc $var1;
        $op = shift @args;
        $var2 = shift @args;
        $var2 = uc $var2;
    } else {
        return $self->parser->throw_error("Error in intermediate code '$line'");
    }
    my $method = $self->pic->validate_operator($op) if defined $op;
    $self->parser->throw_error("Invalid operator '$op' in intermediate code") unless $self->pic->can($method);
    push @code, "\t;; $line" if $self->intermediate_inline;
    my ($code, $funcs, $macros) = $self->pic->$method($var1, $var2, %extra);
    return $self->parser->throw_error("Error in intermediate code '$line'") unless $code;
    push @code, $code if $code;
    $self->_update_funcs($funcs, $macros) if ($funcs or $macros);
    return @code;
}

sub find_tmpvar_dependencies {
    my ($self, $tvar) = @_;
    my $tcode = $self->ast->{tmp_variables}->{$tvar};
    my ($tag, @args) = split /::/, $tcode;
    return unless $tag eq 'OP';
    my @deps = ();
    if (scalar @args == 2) {
        my ($op, $var) = @args;
        if (exists $self->ast->{tmp_variables}->{$var}) {
            push @deps, $var;
            my @rdeps = $self->find_tmpvar_dependencies($var);
            push @deps, @rdeps if @rdeps;
        }
    } elsif (scalar @args == 3) {
        my ($var1, $op, $var2) = @args;
        if (exists $self->ast->{tmp_variables}->{$var1}) {
            push @deps, $var1;
            my @rdeps = $self->find_tmpvar_dependencies($var1);
            push @deps, @rdeps if @rdeps;
        }
        if (exists $self->ast->{tmp_variables}->{$var2}) {
            push @deps, $var2;
            my @rdeps = $self->find_tmpvar_dependencies($var2);
            push @deps, @rdeps if @rdeps;
        }
    } else {
        return $self->parser->throw_error("Error in intermediate code '$tcode'");
    }
    return wantarray ? @deps : \@deps;
}

sub find_var_dependencies {
    my ($self, $tvar) = @_;
    my $tcode = $self->ast->{tmp_variables}->{$tvar};
    my ($tag, @args) = split /::/, $tcode;
    return unless $tag eq 'OP';
    my @deps = ();
    if (scalar @args == 2) {
        my ($op, $var) = @args;
        if (exists $self->ast->{variables}->{$var}) {
            push @deps, $var;
        }
    } elsif (scalar @args == 3) {
        my ($var1, $op, $var2) = @args;
        if (exists $self->ast->{variables}->{$var1}) {
            push @deps, $var1;
        }
        if (exists $self->ast->{variables}->{$var2}) {
            push @deps, $var2;
        }
    } else {
        return $self->parser->throw_error("Error in intermediate code '$tcode'");
    }
    return wantarray ? @deps : \@deps;
}

sub do_i_use_stack {
    my ($self, @deps) = @_;
    return 0 unless @deps;
    my @bits = map { $self->pic->address_bits($_) } @deps;
    return 0 if max(@bits) == $self->pic->register_size;
    return 1;
}

sub generate_code_assign_expr {
    my ($self, $line) = @_;
    my @code = ();
    my $ast = $self->ast;
    my ($tag, $op, $varname, $rhs) = split /::/, $line;
    if (exists $ast->{variables}->{$varname}) {
        if (exists $ast->{tmp_variables}->{$rhs}) {
            my $tmp_code = $ast->{tmp_variables}->{$rhs};
            my @deps = $self->find_tmpvar_dependencies($rhs);
            my @vdeps = $self->find_var_dependencies($rhs);
            push @code, "\t;; TMP_VAR DEPS - $rhs, ". join (',', @deps) if @deps;
            push @code, "\t;; VAR DEPS - ". join (',', @vdeps) if @vdeps;
            push @code, "\t;; $rhs = $tmp_code\n";
            if (scalar @deps) {
                # TODO: have to use stack or check for it
            } else {
                # no tmp-var dependencies
                my $use_stack = $self->do_i_use_stack(@vdeps);
                unless ($use_stack) {
                    my @newcode = $self->generate_code_operations($tmp_code);
                    push @code, @newcode if @newcode;
                    my ($code) = $self->pic->op_ASSIGN_w(uc $varname);
                    return $self->parser->throw_error("Error in intermediate code '$tmp_code'") unless $code;
                    push @code, "\t;; $line" if $self->intermediate_inline;
                    push @code, $code if $code;
                } else {
                    # TODO: stack
                }
            }
        } else {
            my $suffix = '';
            $suffix = '_literal' if $rhs =~ /^\d+$/;
            $suffix = '_variable' if exists $ast->{variables}->{$rhs};
            my $method = $self->pic->validate_operator($op);
            $method .= $suffix if $method;
            $self->parser->throw_error("Invalid operator '$op' in intermediate code") unless $self->pic->can($method);
            my $nvar = $ast->{variables}->{$varname}->{name} || uc $varname;
            my ($code, $funcs, $macros) = $self->pic->$method($nvar, $rhs);
            return $self->parser->throw_error("Error in intermediate code '$line'") unless $code;
            push @code, "\t;; $line" if $self->intermediate_inline;
            push @code, $code if $code;
            $self->_update_funcs($funcs, $macros) if ($funcs or $macros);
        }
    } else {
        return $self->parser->throw_error("Error in intermediate code '$line'");
    }
    return @code;
}

sub generate_code_blocks {
    my ($self, $line, $block) = @_;
    my @code = ();
    my $ast = $self->ast;
    my $mapped_block = $ast->{block_mapping}->{$block}->{block} || $block;
    my ($tag, $label, $child, $parent, $parent_label, $end_label) = split/::/, $line;
    return if ($child eq $block or $child eq $mapped_block or $child eq $parent);
    return if exists $ast->{generated_blocks}->{$child};
    push @code, "\t;; $line" if $self->intermediate_inline;
    my @newcode = $self->generate_code($ast, $child);
    if ($child =~ /^(?:Action|True|False|ISR)/) {
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
        ref $ast->{$parent} eq 'ARRAY' and $parent ne $mapped_block) {
        my ($ptag, $plabel) = split /::/, $ast->{$parent}->[0];
        push @code, "\tgoto $plabel;; $plabel" if $plabel;
    }
    push @code, "\tgoto $label" if $child =~ /^Loop/;
    return @code;
}

sub generate_code_conditionals {
    my ($self, @condblocks) = @_;
    my @code = ();
    if (scalar @condblocks == 1) {
        my $line = shift @condblocks;
        my %hh = split /::/, $line;
        my $ast = $self->ast;
        my $subj = $hh{SUBJ};
        if ($subj =~ /^\d+?$/) { # if subject is a literal
            push @code, "\t;; $line" if $self->intermediate_inline;
        } elsif (exists $ast->{variables}->{$subj}) {

        } elsif (exists $ast->{tmp_variables}->{$subj}) {
            my $tmp_code = $ast->{tmp_variables}->{$subj};
            my @deps = $self->find_tmpvar_dependencies($subj);
            my @vdeps = $self->find_var_dependencies($subj);
            if ($self->intermediate_inline) {
                push @code, "\t;; TMP_VAR DEPS - $subj, ". join (',', @deps) if @deps;
                push @code, "\t;; VAR DEPS - ". join (',', @vdeps) if @vdeps;
                push @code, "\t;; $subj = $tmp_code\n";
            }
            if (scalar @deps) {
                # TODO: have to use stack or check for it
            } else {
                # no tmp-var dependencies
                my $use_stack = $self->do_i_use_stack(@vdeps);
                unless ($use_stack) {
                    my @newcode = $self->generate_code_operations($tmp_code, %hh);
                    push @code, @newcode if @newcode;
                    return $self->parser->throw_error("Error in intermediate code '$tmp_code'")
                        unless @newcode;
                } else {
                    # TODO: stack
                }
            }
        } else {
            return $self->parser->throw_error("Error in intermediate code '$line'");
        }
    }
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
        next unless defined $line;
        if ($line =~ /^BLOCK::\w+/) {
            push @code, $self->generate_code_blocks($line, $block_name);
        } elsif ($line =~ /^INS::\w+/) {
            push @code, $self->generate_code_instruction($line);
        } elsif ($line =~ /^UNARY::\w+/) {
            push @code, $self->generate_code_unary_expr($line);
        } elsif ($line =~ /^SET::\w+/) {
            push @code, $self->generate_code_assign_expr($line);
        } elsif ($line =~ /^LABEL::(\w+)/) {
            push @code, ";; $line" if $self->intermediate_inline;
            push @code, "$1:\n"; # label name
        } elsif ($line =~ /^COND::(\d+)::/) {
            my $cblock = $1;
            my @condblocks = ( $line );
            for my $i (1 .. scalar @$blocks) {
                next unless $blocks->[$i - 1] =~ /^COND::${cblock}::/;
                push @condblocks, $blocks->[$i - 1];
                delete $blocks->[$i - 1];
            }
            push @code, $self->generate_code_conditionals(reverse @condblocks);
        } else {
            $self->parser->throw_error("Intermediate code '$line' cannot be handled");
        }
    }
    return wantarray ? @code : [@code];
}

sub final {
    my ($self, $got) = @_;
    my $ast = $self->ast;
    return $self->parser->throw_error("Missing '}'") if scalar @{$ast->{block_stack}};
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
#    YYY $ast->{tmp_variables};
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
