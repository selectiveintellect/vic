package VIC::PIC::Functions;
use strict;
use warnings;
use bigint;
use Carp;
use POSIX ();
use VIC::PIC::Roles; # load all the roles
use Moo;
use namespace::clean;

sub doesrole {
    return $_[0]->does('VIC::PIC::Roles::' . $_[1]);
}

sub doesroles {
    my $self = shift;
    foreach (@_) {
        return unless $self->doesrole($_);
    }
    return 1;
}

sub validate {
    my ($self, $var) = @_;
    return undef unless defined $var;
    return 0 if $var =~ /^\d+$/;
    return 0 unless $self->doesrole('Chip');
    return 1 if exists $self->pins->{$var};
    return 1 if exists $self->registers->{$var};
    return 0;
}

sub validate_operator {
    my ($self, $op) = @_;
    my $vop = "op_$op" if $op =~ /^
            LE | GE | GT | LT | EQ | NE |
            ADD | SUB | MUL | DIV | MOD |
            BXOR | BOR | BAND | AND | OR | SHL | SHR |
            ASSIGN | INC | DEC | NOT | COMP |
            TBLIDX | ARRIDX | STRIDX
        /x;
    return $vop;
}

sub validate_modifier_operator {
    my ($self, $mod, $suffix) = @_;
    my $vmod = "op_$mod" if $mod =~ /^
            SQRT | HIGH | LOW
        /x;
    return $vmod;
}

sub update_code_config {
    my ($self, $grp, $key, $val) = @_;
    return unless $self->doesrole('CodeGen');
    return unless defined $grp;
    $self->code_config->{$grp} = {} unless exists $self->code_config->{$grp};
    my $grpref = $self->code_config->{$grp};
    if ($key eq 'bits') {
        $val = 8 unless defined $val;
        $val = 8 if $val <= 8;
        $val = 16 if ($val > 8 and $val <= 16);
        $val = 32 if ($val > 16 and $val <= 32);
        carp "$val-bits is not supported. Maximum supported size is 64-bit"
            if $val > 64;
        $val = 64 if $val > 32;
    }
    $val = 1 unless defined $val;
    if (ref $grpref eq 'HASH') {
        $grpref->{$key} = $val;
    } else {
        $self->code_config->{$grp} = { $key => $val };
    }
    1;
}

sub address_bits {
    my ($self, $varname) = @_;
    return unless $self->doesrole('CodeGen');
    my $bits = $self->code_config->{variable}->{bits};
    return $bits unless $varname;
    $bits = $self->code_config->{lc $varname}->{bits} || $bits;
    return $bits;
}

sub _get_gpio_pin {
    my ($self, $ipin) = @_;
    return $ipin if exists $self->gpio_pins->{$ipin};
    # find the correct GPIO pin then matching this pin
    my $pin_no = $self->pins->{$ipin};
    my $allpins = $self->pins->{$pin_no};
    unless (ref $allpins eq 'ARRAY') {
        carp "Invalid data for pin $pin_no";
        return;
    }
    my $opin;
    foreach my $gpio_pin (@$allpins) {
        next unless exists $self->gpio_pins->{$gpio_pin};
        # we have now found the correct gpio_pin for the analog_pin
        $opin = $gpio_pin;
        last;
    }
    return $opin;
}

sub _gpio_select {
    my ($self, $io, $ad, $outp) = @_;
    return unless $self->doesroles(qw(Chip GPIO));
    return unless defined $outp;
    $io = 0 if $io =~ /output/i;
    $io = 1 if $io =~ /input/i;
    $ad = 0 if $ad =~ /digital/i;
    $ad = 1 if $ad =~ /analog/i;
    return unless (($io == 0 or $io == 1) and ($ad == 0 or $ad == 1));
    #TODO: check if banksel works for all chips
    #if not then allow for a way to map instruction codes
    #to something else

    # is this a register
    my ($trisp_code, $port_code, $an_code) = ('', '', '');
    if (exists $self->gpio_ports->{$outp} and
        exists $self->registers->{$outp}) {
        my $trisp = $self->gpio_ports->{$outp};
        my $flags = ($ad == 0) ? 0xFF : 0;
        my $flagsH = ($ad == 0) ? 0xFF : 0;
        if (exists $self->registers->{ANSEL}) {
            # get the pins that belong to the register
            my @portpins = ();
            foreach (keys %{$self->gpio_pins}) {
                push @portpins, $_ if $self->gpio_pins->{$_}->[0] eq $outp;
            }
            foreach (@portpins) {
                my $pin_no = $self->pins->{$_};
                next unless defined $pin_no;
                my $allpins = $self->pins->{$pin_no};
                next unless ref $allpins eq 'ARRAY';
                foreach my $anpin (@$allpins) {
                    next unless exists $self->analog_pins->{$anpin};
                    my ($pno, $pbit) = @{$self->analog_pins->{$anpin}};
                    $flags ^= 1 << $pbit if $pbit < 8;
                    $flagsH ^= 1 << ($pbit - 8) if $pbit >= 8;
                }
            }
            my $iorandwf = ($ad == 0) ? 'andwf' : 'iorwf';
            if ($flags != 0) {
                $flags = sprintf "0x%02X", $flags;
                $an_code .= "\tbanksel ANSEL\n";
                $an_code .= "\tmovlw $flags\n";
                $an_code .= "\t$iorandwf ANSEL, F\n";
            }
            if (exists $self->registers->{ANSELH}) {
                if ($flagsH != 0) {
                    $flagsH = sprintf "0x%02X", $flagsH;
                    $an_code .= "\tbanksel ANSELH\n";
                    $an_code .= "\tmovlw $flagsH\n";
                    $an_code .= "\t$iorandwf ANSELH, F\n";
                }
            }
        }
        if ($io == 0) { # output
            $trisp_code = "\tbanksel $trisp\n\tclrf $trisp";
            $port_code = "\tbanksel $outp\n\tclrf $outp";
        } else { # input
            $trisp_code = "\tbanksel $trisp\n\tmovlw 0xFF\n\tmovwf $trisp";
            $port_code = "\tbanksel $outp";
        }
    } elsif (exists $self->pins->{$outp}) {
        my $gpio_pin = $self->_get_gpio_pin($outp);
        unless (defined $gpio_pin) {
            carp "Cannot find $outp in the list of registers or pins supporting GPIO";
            return;
        }
        my ($port, $trisp, $pinbit) = @{$self->gpio_pins->{$gpio_pin}};
        if (exists $self->registers->{ANSEL}) {
            my $pin_no = $self->pins->{$gpio_pin};
            my $allpins = $self->pins->{$pin_no};
            unless (ref $allpins eq 'ARRAY') {
                carp "Invalid data for pin $pin_no";
                return;
            }
            foreach my $anpin (@$allpins) {
                next unless exists $self->analog_pins->{$anpin};
                my ($pno, $pbit) = @{$self->analog_pins->{$anpin}};
                my $ansel = 'ANSEL';
                if (exists $self->registers->{ANSELH}) {
                    $ansel = ($pbit >= 8) ? 'ANSELH' : 'ANSEL';
                }
                ##TODO: make sure that ANS$pbit exists for all header files
                my $bcfbsf = ($ad == 0) ? 'bcf' : 'bsf';
                $an_code = "\tbanksel $ansel\n\t$bcfbsf $ansel, ANS$pbit";
                last;
            }
        }
        if ($io == 0) { # output
            $trisp_code = "\tbanksel $trisp\n\tbcf $trisp, $trisp$pinbit";
            $port_code = "\tbanksel $port\n\tbcf $port, $pinbit";
        } else { # input
            $trisp_code = "\tbanksel $trisp\n\tbsf $trisp, $trisp$pinbit";
            $port_code = "\tbanksel $port";
        }
    } else {
        carp "Cannot find $outp in the list of registers or pins supporting GPIO";
        return;
    }
    return << "...";
$trisp_code
$an_code
$port_code
...
}

sub digital_output {
    my $self = shift;
    return $self->_gpio_select(output => 'digital', @_);
}

sub digital_input {
    my $self = shift;
    return $self->_gpio_select(input => 'digital', @_);
}

sub analog_input {
    my $self = shift;
    return $self->_gpio_select(input => 'analog', @_);
}

sub write {
    my ($self, $outp, $val) = @_;
    return unless $self->doesroles(qw(CodeGen Chip GPIO));
    return unless defined $outp;
    if (exists $self->gpio_ports->{$outp} and
        exists $self->registers->{$outp}) {
        my $port = $self->ports->{$outp};
        unless (defined $val) {
            return << "...";
\tclrf $outp
\tcomf $outp, 1
...
        }
        if ($self->validate($val)) {
            # ok we want to write the value of a pin to a port
            # that doesn't seem right so let's provide a warning
            if ($self->pins->{$val}) {
                carp "$val is a pin and you're trying to write a pin to a port" .
                    " $outp. You can write a pin to a pin or a port to a port only.\n";
                return;
            }
        }
        return $self->op_ASSIGN($outp, $val);
    } elsif (exists $self->pins->{$outp}) {
        my $gpio_pin = $self->_get_gpio_pin($outp);
        unless (defined $gpio_pin) {
            carp "Cannot find $outp in the list of ports, register or pins to write to";
            return;
        }
        my ($port, $trisp, $pinbit) = @{$self->gpio_pins->{$gpio_pin}};
        if ($val =~ /^\d+$/) {
            return "\tbcf $port, $pinbit\n" if "$val" eq '0';
            return "\tbsf $port, $pinbit\n" if "$val" eq '1';
            carp "$val cannot be applied to a pin $outp\n";
            return;
        } elsif (exists $self->pins->{$val}) {
            # ok we want to short two pins, and this is not bit-banging
            # although seems like it
            my $vpin = $self->_get_gpio_pin($val);
            if ($vpin) {
                my ($vport, $vtris, $vpinbit) = @{$self->gpio_pins->{$vpin}};
                return << "...";
\tbtfss $vport, $vpin
\tbcf $port, $outp
\tbtfsc $vport, $vpin
\tbsf $port, $outp
...
            } else {
                carp "$val is a port or unknown pin and cannot be written to a pin $outp. ".
                    "Only a pin can be written to a pin.\n";
                return;
            }
        }
        return $self->op_ASSIGN($port, $val);
    } elsif (exists $self->registers->{$outp}) { # write a value to a register
        my $code = "\tbanksel $outp\n";
        $code .= $self->op_ASSIGN($outp, $val);
        return $code;
    } else {
        carp "Cannot find $outp in the list of ports, register or pins to write to";
        return;
    }
}

1;
__END__
