package VIC::PIC::P16F690;
use strict;
use warnings;
use POSIX ();
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

sub delay {
    my ($self, $ins, $t) = @_;
    return '' if $t <= 0;
    # divide the time into component seconds, milliseconds and microseconds
    my $sec = POSIX::floor($t / 1e6);
    my $ms = POSIX::floor(($t - $sec * 1e6) / 1000);
    my $us = $t - $sec * 1e6 - $ms * 1000;
    my $code = '';
    my $funcs = {};
    ## more than one function could be called so have them separate
    if ($sec > 0) {
        my $fn = "_delay_${sec}s";
        $code .= "call $fn\n";
        $funcs->{$fn} = <<"....";
m_delay_s D'$sec'
return
....
    }
    if ($ms > 0) {
        my $fn = "_delay_${ms}ms";
        $code .= "call $fn\n";
        $funcs->{$fn} = <<"....";
m_delay_ms D'$ms'
return
....
    }
    if ($us > 0) {
        my $fn = "_delay_${us}us";
        $code .= "call $fn\n";
        $funcs->{$fn} = <<"....";
m_delay_us D'$us'
return
....
    }
    return wantarray ? ($code, $funcs) : $code;
}

1;
