use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

Main {
    digital_output PORTC;
    $display = 0x08; # create a 8-bit register by checking size
    sim_assert $display == 0x08, "$display should be 0x08";
    Loop {
        write PORTC, $display;
        delay 100ms;
        # improve this depiction
        # circular rotate right by 1 bit
        ror $display, 1;
    }
}

Simulator {
    attach_led PORTC, 4; # attach 4 LEDs to PORTC on RC0-RC3;
    limit 60s;
    logfile "rotater.lxt";
    log PORTC;
    scope PORTC;
}
...

my $output = <<'...';
;;;; generated code for PIC header file
#include <p16f690.inc>
;;;; generated code for gpsim header file
#include <coff.inc>

;;;; generated code for variables
GLOBAL_VAR_UDATA udata
DISPLAY res 1
    global DISPLAY

;;;;;; DELAY FUNCTIONS ;;;;;;;

VIC_VAR_DELAY_UDATA udata
VIC_VAR_DELAY   res 3



;;;; generated code for macros
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
    movwf   VIC_VAR_DELAY + 1
_delay_msecs_loop_1:
    clrf   VIC_VAR_DELAY   ;; set to 0 which gets decremented to 0xFF
_delay_msecs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delay_msecs_loop_0
    decfsz  VIC_VAR_DELAY + 1, F
    goto    _delay_msecs_loop_1
    endm



	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)



	org 0

;;;; generated common code for the Simulator
	.sim "module library libgpsim_modules"
	.sim "p16f690.xpos = 200";
	.sim "p16f690.ypos = 200";

;;;; generated code for Simulator
	.sim "module load led L0"
	.sim "L0.xpos = 100"
	.sim "L0.ypos = 50"
	.sim "node portc0led"
	.sim "attach portc0led portc0 L0.in"
	.sim "module load led L1"
	.sim "L1.xpos = 100"
	.sim "L1.ypos = 100"
	.sim "node portc1led"
	.sim "attach portc1led portc1 L1.in"
	.sim "module load led L2"
	.sim "L2.xpos = 100"
	.sim "L2.ypos = 150"
	.sim "node portc2led"
	.sim "attach portc2led portc2 L2.in"
	.sim "module load led L3"
	.sim "L3.xpos = 100"
	.sim "L3.ypos = 200"
	.sim "node portc3led"
	.sim "attach portc3led portc3 L3.in"

	.sim "break c 600000000"

	.sim "log lxt rotater.lxt"

	.sim "log r portc"
	.sim "log w portc"
    .sim "scope.ch0 = \"portc0\""
    .sim "scope.ch1 = \"portc1\""
    .sim "scope.ch2 = \"portc2\""
    .sim "scope.ch3 = \"portc3\""
    .sim "scope.ch4 = \"portc4\""
    .sim "scope.ch5 = \"portc5\""
    .sim "scope.ch6 = \"portc6\""
    .sim "scope.ch7 = \"portc7\""

;;;; generated code for Main
_start:

	banksel TRISC
	clrf TRISC
	banksel ANSEL
	movlw 0x0F
	andwf ANSEL, F
	banksel ANSELH
	movlw 0xFC
	andwf ANSELH, F

	banksel PORTC
	clrf PORTC

	;; moves 8 (0x08) to DISPLAY
	movlw 0x08
	movwf DISPLAY
	.assert "DISPLAY == 0x08, \"$display should be 0x08\""
	nop ;; needed for the assert

;;;; generated code for Loop1
_loop_1:

	;; moving DISPLAY to PORTC
	movf DISPLAY, W
	movwf PORTC

	call _delay_100ms

	bcf STATUS, C
	rrf DISPLAY, 1
	btfsc STATUS, C
	bsf DISPLAY, 7

	goto _loop_1 ;;;; end of _loop_1

_end_loop_1:

_end_start:

	goto $	;;;; end of Main

;;;; generated code for functions
_delay_100ms:
	m_delay_ms D'100'
	return


;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
