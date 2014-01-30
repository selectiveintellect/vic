use lib 'pegex-pm/lib', '../pegex-pm/lib';
use Test::VIC tests => 1;

my $input = <<'...';
PIC P16F690;

set_config;

# A Comment

set_org 0;

Main {
     output_port 'C', 0;
     Loop {
         port_value 'C', 0, 0x1;
         delay 1s;
         port_value 'C', 0, 0;
         delay 1s;
     }
}
...

my $output = <<'...';
#include <p16f690.inc>

DELAY_VAR_UDATA udata
DELAY_VAR   res 3

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

    __config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

     org 0

_start:
    banksel   TRISC
    bcf       TRISC, TRISC0
    banksel   PORTC
_loop_1:
    bsf PORTC, 0
    call _delay_1s
    bcf PORTC, 0
    call _delay_1s
    goto _loop_1

_delay_1s:
    m_delay_s D'1'
    return

    end
...
compiles_ok($input, $output);
