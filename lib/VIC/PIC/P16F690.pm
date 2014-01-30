package VIC::PIC::P16F690;
use strict;
use warnings;
use POSIX ();
use Pegex::Base; # use this instead of Mo

has type => 'p16f690';

has include => 'p16f690.inc';

has org => 0;

has config => <<'...';
__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)
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

sub m_delay_var {
    return <<'...';
;;;;;; DELAY FUNCTIONS ;;;;;;;

DELAY_VAR_UDATA udata
DELAY_VAR   res 3

...
}

sub m_delay_us {
    return <<'...';
;; 1MHz => 1us per instruction
;; return, goto and call are 2us each
;; hence each loop iteration is 3us
;; the rest including movxx + return = 2us
;; hence usecs - 6 is used
m_delay_us macro usecs
    local _delay_usecs_loop_0
    variable usecs_1 = 0
if (usecs > D'6')
usecs_1 = usecs / D'3'
    movlw   usecs_1
    movwf   DELAY_VAR
_delay_usecs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delay_usecs_loop_0
else
    while usecs_1 < usecs
        nop
usecs_1++
    endw
endif
    endm
...
}

sub m_delay_ms {
    return <<'...';
;; 1MHz => 1us per instruction
;; each loop iteration is 3us each
;; there are 2 loops, one for (768 + 3) us
;; and one for the rest in ms
;; we add 3 instructions for the outer loop
;; number of outermost loops = msecs * 1000 / 771 = msecs * 13 / 10
m_delay_ms macro msecs
    local _delay_msecs_loop_0, _delay_msecs_loop_1
    variable msecs_1 = 0
msecs_1 = (msecs * D'13') / D'10'
    movlw   msecs_1
    movwf   DELAY_VAR + 1
_delay_msecs_loop_1:
    clrf   DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delay_msecs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delay_msecs_loop_0
    decfsz  DELAY_VAR + 1, F
    goto    _delay_msecs_loop_1
    endm
...
}

sub m_delay_s {
    return <<'...';
;; 1MHz => 1us per instruction
;; each loop iteration is 3us each
;; there are 2 loops, one for (768 + 3) us
;; and one for the rest in ms
;; we add 3 instructions for the outermost loop
;; 771 * 256 + 3 = 197379 ~= 200000
;; number of outermost loops = seconds * 1000000 / 200000 = seconds * 5
m_delay_s macro secs
    local _delay_secs_loop_0, _delay_secs_loop_1, _delay_secs_loop_2
    variable secs_1 = 0
secs_1 = secs * D'1000000' / D'197379'
    movlw   secs_1
    movwf   DELAY_VAR + 2
_delay_secs_loop_2:
    clrf    DELAY_VAR + 1   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_1:
    clrf    DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delay_secs_loop_0
    decfsz  DELAY_VAR + 1, F
    goto    _delay_secs_loop_1
    decfsz  DELAY_VAR + 2, F
    goto    _delay_secs_loop_2
    endm
...
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
    my $macros = { m_delay_var => $self->m_delay_var };
    ## more than one function could be called so have them separate
    if ($sec > 0) {
        my $fn = "_delay_${sec}s";
        $code .= "call $fn\n";
        $funcs->{$fn} = <<"....";
m_delay_s D'$sec'
return
....
        $macros->{m_delay_s} = $self->m_delay_s;
    }
    if ($ms > 0) {
        my $fn = "_delay_${ms}ms";
        $code .= "call $fn\n";
        $funcs->{$fn} = <<"....";
m_delay_ms D'$ms'
return
....
        $macros->{m_delay_ms} = $self->m_delay_ms;
    }
    if ($us > 0) {
        my $fn = "_delay_${us}us";
        $code .= "call $fn\n";
        $funcs->{$fn} = <<"....";
m_delay_us D'$us'
return
....
        $macros->{m_delay_us} = $self->m_delay_us;
    }
    return wantarray ? ($code, $funcs, $macros) : $code;
}

1;
