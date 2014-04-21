use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

Main {
    digital_output PORTC;
    $display = 0x08; # create a 8-bit register by checking size
    Loop {
        write PORTC, $display;
        delay 1s;
        # improve this depiction
        # circular rotate right by 1 bit
        ror $display, 1;
    }
}
...

my $output = <<'...';
#include <p16f690.inc>

GLOBAL_VAR_UDATA udata
DISPLAY res 1

VIC_VAR_DELAY_UDATA udata
VIC_VAR_DELAY   res 3

m_delay_s macro secs
    local _delay_secs_loop_0, _delay_secs_loop_1, _delay_secs_loop_2
    variable secs_1 = 0
secs_1 = secs * D'1000000' / D'197379'
    movlw   secs_1
    movwf   VIC_VAR_DELAY + 2
_delay_secs_loop_2:
    clrf    VIC_VAR_DELAY + 1   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_1:
    clrf    VIC_VAR_DELAY   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delay_secs_loop_0
    decfsz  VIC_VAR_DELAY + 1, F
    goto    _delay_secs_loop_1
    decfsz  VIC_VAR_DELAY + 2, F
    goto    _delay_secs_loop_2
    endm

__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

org 0

_start:
    ;; turn on PORTC's pin 0 as output
    banksel TRISC
    clrf TRISC
    banksel ANSEL
    movlw 0x0F
    andwf ANSEL, F
    banksel ANSELH
    movlw 0xFC
    andwf ANSELH, F
    banksel PORTC
    clrf    PORTC

    movlw  0x08
    movwf DISPLAY
_loop_1:
    movf DISPLAY, W
    movwf PORTC
    call _delay_1s
    ;; ror
    bcf STATUS, C
    rrf DISPLAY, 1
    btfsc STATUS, C
    bsf DISPLAY, 7
    goto _loop_1
_end_loop_1:
_end_start:
    goto $

_delay_1s:
    m_delay_s D'1'
    return

     end
...

compiles_ok($input, $output);
