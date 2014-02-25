package VIC::PIC;
use strict;
use warnings;
use POSIX ();

our $VERSION = '0.03';
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
    conditionals => 0,
};

sub throw_error { shift->parser->throw_error(@_); }

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
        my $label = $1 if $block_label =~ /^\s*(\w+):/;
        $block_label = "LABEL::${label}::$block" if $label;
        ## do not allow the parent to be a label
        if (defined $parent) {
            unless ($parent =~ /LABEL::/) {
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
        push @$stack, "_start:\n";
    } elsif ($block =~ /^Loop/) {
        push @$stack, "_loop_$id:\n";
    } elsif ($block =~ /^Action/) {
        push @$stack, "_action_$id:\n";
    } elsif ($block =~ /^True/) {
        push @$stack, "_true_$id:\n";
    } elsif ($block =~ /^False/) {
        push @$stack, "_false_$id:\n";
    } elsif ($block =~ /^ISR/) {
        push @$stack, "_isr_$id:\n";
    } else {
        my $lcb = lc "_$block";
        push @$stack, "$lcb:\n";
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
    $self->flatten($list);
    return shift(@$list);
}

sub _update_block {
    my ($self, $code, $funcs, $macros) = @_;
    my $top = $self->ast->{block_stack_top};
    $top = $top - 1 if $top > 0;
    my $block = $self->ast->{block_stack}->[$top];
    push @{$self->ast->{$block}}, $code if $block;
    return unless ref $funcs eq 'HASH';
    foreach (keys %$funcs) {
        $self->ast->{funcs}->{$_} = $funcs->{$_};
    }
    return unless ref $macros eq 'HASH';
    foreach (keys %$macros) {
        $self->ast->{macros}->{$_} = $macros->{$_};
    }
}

sub got_instruction {
    my ($self, $list) = @_;
    my $method = shift @$list;
    $self->flatten($list) if $list;
    my @args = @$list if $list;
    return $self->throw_error("Unknown instruction '$method'") unless $self->pic->can($method);
    my ($code, $funcs, $macros) = $self->pic->$method(@args);
    return $self->throw_error("Error in statement '$method @args'") unless $code;
    $self->_update_block($code, $funcs, $macros);
    return;
}

sub _handle_var_op {
    my ($self, $varname, $op) = @_;
    my $method = 'increment' if $op eq '++';
    $method = 'decrement' if $op eq '--';
    return $self->throw_error("Operator '$op' not supported. Use -- or ++ only.") unless $method;
    return $self->throw_error("Unknown instruction '$method'") unless $self->pic->can($method);
    my $nvar = $self->ast->{variables}->{$varname}->{name} || uc $varname;
    my $code = $self->pic->$method($nvar);
    return $self->throw_error("Invalid expression '$varname $op'") unless $code;
    $self->_update_block($code);
    return;
}

sub got_lhs_op {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $varname = shift @$list;
    my $op = shift @$list;
    return $self->_handle_var_op($varname, $op);
}

sub got_op_rhs {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $op = shift @$list;
    my $varname = shift @$list;
    return $self->_handle_var_op($varname, $op);
}

sub got_lhs_op_rhs {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $varname = shift @$list;
    my $op = shift @$list;
    my $rhs = shift @$list;
    my $method = 'assign_' if $op eq '=';
    $method = 'selfadd_' if $op eq '+=';
    my $suffix = 'expression';
    $suffix = 'literal' if $rhs =~ /^\d+$/;
    $suffix = 'variable' if exists $self->ast->{variables}->{$rhs};
    $method .= $suffix if $suffix;
#    YYY $rhs, $list;
    return $self->throw_error("Operator '$op' not supported") unless $method;
    return $self->throw_error("Unknown method '$method'") unless $self->pic->can($method);
    my $nvar = $self->ast->{variables}->{$varname}->{name} || uc $varname;
    my $code = $self->pic->$method($nvar, $rhs, @$list);
    return $self->throw_error("Invalid expression '$varname $op $rhs'") unless $code;
    $self->_update_block($code);
    return;
}

sub got_conditional {
    my ($self, $list) = @_;
    my ($subject, $predicate) = @$list;
    $self->flatten($predicate);
    return unless scalar @$predicate;
    #YYY $self->stack;
    $self->flatten($subject);
    my ($lhs, $method, $rhs) = @$subject; #FIXME: does this work with multiple?
    return $self->throw_error("Unknown method '$method'") unless $self->pic->can($method);
    my $ccount = $self->ast->{conditionals};
    my ($code, $funcs, $macros) = $self->pic->$method($lhs, $rhs, $predicate, $ccount);
    $self->throw_error("Unable to generate code for comparison expression"), return unless $code;
    $self->_update_block($code, $funcs, $macros);
    $self->ast->{conditionals}++;
    return;
}

sub got_compare_operator {
    my ($self, $op) = @_;
    my $method = 'check_eq' if $op eq '==';
    $method = 'check_ne' if $op eq '!=';
    $method = 'check_le' if $op eq '<=';
    $method = 'check_ge' if $op eq '>=';
    $method = 'check_lt' if $op eq '<';
    $method = 'check_gt' if $op eq '>';
    return $self->throw_error("Operator '$op' not supported") unless $method;
    return $method;
}

sub got_expr_value {
    my ($self, $list) = @_;
    if (ref $list eq 'ARRAY') {
        $self->flatten($list);
        if (scalar @$list > 1) {
            my ($op, $varname) = @$list;
            return "OP::NOT::$varname" if $op eq '!';
            return "OP::COMP::$varname" if $op eq '~';
            $self->throw_error("Unary operator '$op' not supported");
            return;
        } else {
            return shift @$list;
        }
    } else {
        return $list;
    }
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
    return $self->throw_error("'$varname' is not a valid part of the " . uc $self->pic->type);
    return;
}

sub got_variable {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $varname = shift @$list;
    $self->ast->{variables}->{$varname} = {
        name => uc $varname,
        scope => $self->ast->{block_stack_top},
        size => POSIX::ceil($self->pic->address_bits / 8),
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

sub _generate_code {
    my ($ast, $block) = @_;
    my @code = ();
    return wantarray ? @code : [] unless defined $ast;
    return wantarray ? @code : [] unless exists $ast->{$block};
    $ast->{generated_blocks} = {} unless defined $ast->{generated_blocks};
    push @code, ";;;; generated code for $block";
    foreach my $line (@{$ast->{$block}}) {
        if ($line =~ /LABEL::([\w\:]+)/) {
            my ($label, $child, $parent, $parent_label, $end_label) = split/::/, $1;
            next if $child eq $parent; # bug - FIXME
            next if $child eq $block; # bug - FIXME
            next if exists $ast->{generated_blocks}->{$child};
            my @newcode = _generate_code($ast, $child);
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
        } else {
            push @code, $line;
        }
    }
    return wantarray ? @code : [@code];
}

sub final {
    my ($self, $got) = @_;
    my $ast = $self->ast;
    return $self->throw_error("Missing '}'") if $self->ast->{block_stack_top} ne 0;
    return $self->throw_error("Main not defined") unless defined $self->ast->{Main};
    # generate main code first so that any addition to functions, macros,
    # variables during generation can be handled after
    my @main_code = _generate_code($ast, 'Main');
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
