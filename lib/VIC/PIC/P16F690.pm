package VIC::PIC::P16F690;
use strict;
use warnings;
use Pegex::Base; # use this instead of Mo

has type => 'p16f690';

has include => 'p16f690.inc';

has org => 0;

has config => <<'...';
__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF &
            _BOR_OFF & _IESO_OFF & _FCMEN_OFF)
...

sub output_port {
    my ($self, $ins, $port, $pin) = @_;
    return undef unless $port =~ /^[A-C]$/;
    my $code = "clrf TRIS$port" if
        (not defined $pin or $pin > 7);
    $code = "bcf TRIS$port, TRIS$port$pin" if (defined $pin and $pin < 7);
    return << "...";
banksel TRIS$port
$code
banksel PORT$port
...
}

sub port_value {
    my ($self, $ins, $port, $pin, $val) = @_;
    return undef unless $port =~ /^[A-C]$/;
    # if pin is not set set all values
    unless (defined $val or defined $pin) {
        return << "...";
clrf PORT$port
comf PORT$port, 1
...
    }
    return "clrf PORT$port\n" unless defined $pin;
    return undef if $pin > 7;
    return $val ? "bsf PORT$port, $pin\n" :
                  "bcf PORT$port, $pin\n";
}

sub hang {
    my ($self, $ins, @args) = @_;
    return 'goto $';
}

1;
