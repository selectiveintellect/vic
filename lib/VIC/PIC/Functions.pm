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

sub digital_output {
    my ($self, $outp) = @_;
    return unless $self->doesrole('Chip');
    return unless $self->doesrole('GPIO');
    return unless defined $outp;
    my $code;
    # is this a register
    if (exists $self->gpio_ports->{$outp} and
        exists $self->registers->{$outp}) {
        my $trisp = $self->gpio_ports->{$outp};
        my $flags = 0xFF;
        my $flagsH = 0xFF;
        my $an_code = '';
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
            if ($flags != 0) {
                $flags = sprintf "0x%02X", $flags;
                $an_code .= "\tbanksel ANSEL\n";
                $an_code .= "\tmovlw $flags\n";
                $an_code .= "\tandwf ANSEL, F\n";
            }
            if (exists $self->registers->{ANSELH}) {
                if ($flagsH != 0) {
                    $flagsH = sprintf "0x%02X", $flagsH;
                    $an_code .= "\tbanksel ANSELH\n";
                    $an_code .= "\tmovlw $flagsH\n";
                    $an_code .= "\tandwf ANSELH, F\n";
                }
            }
        }
        $code = << "...";
\tbanksel $trisp
\tclrf $trisp
$an_code
\tbanksel $outp
\tclrf $outp
...
    } elsif (exists $self->pins->{$outp} and
        exists $self->gpio_pins->{$outp}) {
        my ($port, $trisp, $pinbit) = @{$self->gpio_pins->{$outp}};
        my $an_code = '';
        if (exists $self->registers->{ANSEL}) {
            my $pin_no = $self->pins->{$outp};
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
                ##XXX: make sure that ANS$pbit exists for all header files
                $an_code = "\tbanksel $ansel\n\tbcf $ansel, ANS$pbit";
                last;
            }
        }
            $code = << "...";
\tbanksel $trisp
\tbcf $trisp, $trisp$pinbit
$an_code
\tbanksel $port
\tbcf $port, $pinbit
...
    } else {
        carp "Cannot find $outp in the list of registers or pins supporting digital output";
    }
    return $code;
}

1;
__END__
