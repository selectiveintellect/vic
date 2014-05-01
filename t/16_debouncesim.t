use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

pragma debounce count = 5;
pragma debounce delay = 1ms;

Main {
    digital_output PORTC;
    digital_input RA3;
    $display = 0;
    Loop {
        # test breaking of arguments over multiple lines
        debounce RA3,
        Action {
            ++$display;
            write PORTC, $display;
        };
    }
}

Simulator {
    autorun;
    attach_led PORTC, 4, 'red';
    logfile "debouncer.lxt";
    log RA3;
    scope RA3;
    stimulate RA3, every 1ms, wave [
        300, 1, 400, 0, 420, 1,
        500, 0, 520, 1, 600, 0
    ];
    stop_after 10s;
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

;;;;;; VIC_VAR_DEBOUNCE VARIABLES ;;;;;;;

VIC_VAR_DEBOUNCE_VAR_IDATA idata
;; initialize state to 1
VIC_VAR_DEBOUNCESTATE db 0x01
;; initialize counter to 0
VIC_VAR_DEBOUNCECOUNTER db 0x00



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
	.sim "L0.color = red"
	.sim "node portc0led"
	.sim "attach portc0led portc0 L0.in"
	.sim "module load led L1"
	.sim "L1.xpos = 100"
	.sim "L1.ypos = 100"
	.sim "L1.color = red"
	.sim "node portc1led"
	.sim "attach portc1led portc1 L1.in"
	.sim "module load led L2"
	.sim "L2.xpos = 100"
	.sim "L2.ypos = 150"
	.sim "L2.color = red"
	.sim "node portc2led"
	.sim "attach portc2led portc2 L2.in"
	.sim "module load led L3"
	.sim "L3.xpos = 100"
	.sim "L3.ypos = 200"
	.sim "L3.color = red"
	.sim "node portc3led"
	.sim "attach portc3led portc3 L3.in"

	.sim "log lxt debouncer.lxt"

	.sim "log r porta"
	.sim "log w porta"

	.sim "scope.ch0 = \"porta3\""

	.sim "echo creating stimulus number 0"
	.sim "stimulus asynchronous_stimulus"
	.sim "initial_state 0"
	.sim "start_cycle 0"
	.sim "digital"
	.sim "period 1000"
	.sim "{ 300,1,400,0,420,1,500,0,520,1,600,0 }"
	.sim "name stim0"
	.sim "end"
	.sim "echo done creating stimulus number 0"
	.sim "node stim0RA3"
	.sim "attach stim0RA3 stim0 porta3"

	.sim "break c 100000000"
    .sim "run"

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

	banksel TRISA
	bsf TRISA, TRISA3

	banksel PORTA

	;; moves 0 (0x00) to DISPLAY
	clrf DISPLAY

;;;; generated code for Loop1
_loop_1:

	;;; generate code for debounce A<3>
	call _delay_1ms

	;; has debounce state changed to down (bit 0 is 0)
	;; if yes go to debounce-state-down
	btfsc   VIC_VAR_DEBOUNCESTATE, 0
	goto    _debounce_state_up
_debounce_state_down:
	clrw
	btfss   PORTA, 3
	;; increment and move into counter
	incf    VIC_VAR_DEBOUNCECOUNTER, 0
	movwf   VIC_VAR_DEBOUNCECOUNTER
	goto    _debounce_state_check

_debounce_state_up:
	clrw
	btfsc   PORTA, 3
	incf    VIC_VAR_DEBOUNCECOUNTER, 0
	movwf   VIC_VAR_DEBOUNCECOUNTER
	goto    _debounce_state_check

_debounce_state_check:
	movf    VIC_VAR_DEBOUNCECOUNTER, W
	xorlw   0x05
	;; is counter == 0x05 ?
	btfss   STATUS, Z
	goto    _end_action_2
	;; after 0x05 straight, flip direction
	comf    VIC_VAR_DEBOUNCESTATE, 1
	clrf    VIC_VAR_DEBOUNCECOUNTER
	;; was it a key-down
	btfss   VIC_VAR_DEBOUNCESTATE, 0
	goto    _end_action_2
	goto    _action_2
_end_action_2:


	goto _loop_1 ;;;; end of _loop_1

_end_loop_1:

_end_start:

	goto $	;;;; end of Main

;;;; generated code for functions
;;;; generated code for Action2
_action_2:

	;; increments DISPLAY in place
	;; increment byte[0]
	incf DISPLAY, F

	;; moving DISPLAY to PORTC
	movf DISPLAY, W
	movwf PORTC

	goto _end_action_2 ;; go back to end of block

;;;; end of _action_2
_delay_1ms:
	m_delay_ms D'1'
	return


;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
