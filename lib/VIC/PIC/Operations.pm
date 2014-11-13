package VIC::PIC::Operations;
use strict;
use warnings;
use bigint;
use Carp;
use POSIX ();
use VIC::PIC::Roles; # load all the roles
use Moo;
use namespace::clean;

sub doesrole {
    my $a = $_[0]->does('VIC::PIC::Roles::' . $_[1]);
    carp ref($_[0]) . " does not do role $_[1]" unless $a;
    return $a;
}

sub doesroles {
    my $self = shift;
    foreach (@_) {
        return unless $self->doesrole($_);
    }
    return 1;
}

sub _assign_literal {
    my ($self, $var, $val) = @_;
    return unless $self->doesrole('CodeGen'); # needed for address_bits
    my $bits = $self->address_bits($var);
    my $bytes = POSIX::ceil($bits / 8);
    my $nibbles = 2 * $bytes;
    $var = uc $var;
    my $code = sprintf "\t;; moves $val (0x%0${nibbles}X) to $var\n", $val;
    if ($val >= 2 ** $bits) {
        carp "Warning: Value $val doesn't fit in $bits-bits";
        $code .= "\t;; $val doesn't fit in $bits-bits. Using ";
        $val &= (2 ** $bits) - 1;
        $code .= sprintf "%d (0x%0${nibbles}X)\n", $val, $val;
    }
    if ($val == 0) {
        $code .= "\tclrf $var\n";
        for (2 .. $bytes) {
            $code .= sprintf "\tclrf $var + %d\n", ($_ - 1);
        }
    } else {
        my $valbyte = $val & ((2 ** 8) - 1);
        $code .= sprintf "\tmovlw 0x%02X\n\tmovwf $var\n", $valbyte if $valbyte > 0;
        $code .= "\tclrf $var\n" if $valbyte == 0;
        for (2 .. $bytes) {
            my $k = $_ * 8;
            my $i = $_ - 1;
            my $j = $i * 8;
            # get the right byte. 64-bit math requires bigint
            $valbyte = (($val & ((2 ** $k) - 1)) & (2 ** $k - 2 ** $j)) >> $j;
            $code .= sprintf "\tmovlw 0x%02X\n\tmovwf $var + $i\n", $valbyte if $valbyte > 0;
            $code .= "\tclrf $var + $i\n" if $valbyte == 0;
        }
    }
    return $code;
}

sub op_assign {
    my ($self, $var1, $var2, %extra) = @_;
    return unless $self->doesrole('Operations');
    my $literal = qr/^\d+$/;
    return $self->_assign_literal($var1, $var2) if $var2 =~ $literal;
    my $b1 = POSIX::ceil($self->address_bits($var1) / 8);
    my $b2 = POSIX::ceil($self->address_bits($var2) / 8);
    $var2 = uc $var2;
    $var1 = uc $var1;
    my $code = "\t;; moving $var2 to $var1\n";
    if ($b1 == $b2) {
        $code .= "\tmovf $var2, W\n\tmovwf $var1\n";
        for (2 .. $b1) {
            my $i = $_ - 1;
            $code .= "\tmovf $var2 + $i, W\n\tmovwf $var1 + $i\n";
        }
    } elsif ($b1 > $b2) {
        # we are moving a smaller var into a larger var
        $code .= "\t;; $var2 has a smaller size than $var1\n";
        $code .= "\tmovf $var2, W\n\tmovwf $var1\n";
        for (2 .. $b2) {
            my $i = $_ - 1;
            $code .= "\tmovf $var2 + $i, W\n\tmovwf $var1 + $i\n";
        }
        $code .= "\t;; we practice safe assignment here. zero out the rest\n";
        # we practice safe mathematics here. zero-out the rest of the place
        $b2++;
        for ($b2 .. $b1) {
            $code .= sprintf "\tclrf $var1 + %d\n", ($_ - 1);
        }
    } elsif ($b1 < $b2) {
        # we are moving a larger var into a smaller var
        $code .= "\t;; $var2 has a larger size than $var1. truncating..,\n";
        $code .= "\tmovf $var2, W\n\tmovwf $var1\n";
        for (2 .. $b1) {
            my $i = $_ - 1;
            $code .= "\tmovf $var2 + $i, W\n\tmovwf $var1 + $i\n";
        }
    } else {
        carp "Warning: should never reach here: $var1 is $b1 bytes and $var2 is $b2 bytes";
    }
    $code .= $self->op_assign_wreg($extra{RESULT}) if $extra{RESULT};
    return $code;
}

sub op_assign_wreg {
    my ($self, $var) = @_;
    return unless $self->doesrole('Operations');
    return unless $var;
    $var = uc $var;
    return "\tmovwf $var\n";
}

1;
__END__

