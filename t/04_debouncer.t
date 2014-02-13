use lib 'pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

config debounce count = 5;
config debounce delay = 1ms;

Main {
    output_port 'C';
    digital_input_port 'A', 3; # pin 3 is digital, rest analog
    $display = 0;
    Loop {
        debounce 'A', 3, Action {
            $display++;
            port_value 'C', 0xFF, $display;
        };
    }
}
...

my $output = <<'...';
;;;; generated code for PIC header file
#include <p16f690.inc>

;;;; generated code for variables
GLOBAL_VAR_UDATA udata
DISPLAY res 1

;;;;;; DELAY FUNCTIONS ;;;;;;;

DELAY_VAR_UDATA udata
DELAY_VAR   res 3



;;;;;; DEBOUNCE VARIABLES ;;;;;;;

DEBOUNCE_VAR_IDATA idata
;; initialize state to 1
DEBOUNCESTATE db 0x01
;; initialize counter to 0
DEBOUNCECOUNTER db 0x00



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
    movwf   DELAY_VAR + 1
_delay_msecs_loop_1:
    clrf   DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delay_msecs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delay_msecs_loop_0
    decfsz  DELAY_VAR + 1, F
    goto    _delay_msecs_loop_1
    endm



	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

	org 0

;;;; generated code for Main
_start:

	banksel TRISC
	clrf TRISC
	banksel PORTC
	clrf PORTC

	banksel TRISA
	bcf TRISA, TRISA3
	banksel ANSEL
	movlw 0xFF
	movwf ANSEL
	banksel PORTA

	clrf DISPLAY

;;;; generated code for Loop1
_loop_1:

	;;; generate code for debounce A<3>
	call _delay_1ms

	;; has debounce state changed to down (bit 0 is 0)
	;; if yes go to debounce-state-down
	btfsc   DEBOUNCESTATE, 0
	goto    _debounce_state_up
_debounce_state_down:
	clrw
	btfss   PORTA, 3
	;; increment and move into counter
	incf    DEBOUNCECOUNTER, 0
	movwf   DEBOUNCECOUNTER
	goto    _debounce_state_check

_debounce_state_up:
	clrw
	btfsc   PORTA, 3
	incf    DEBOUNCECOUNTER, 0
	movwf   DEBOUNCECOUNTER
	goto    _debounce_state_check

_debounce_state_check:
	movf    DEBOUNCECOUNTER, W
	xorlw   5
	;; is counter == 5 ?
	btfss   STATUS, Z
	goto    _loop_1
	;; after 5 straight, flip direction
	comf    DEBOUNCESTATE, 1
	clrf    DEBOUNCECOUNTER
	;; was it a key-down
	btfss   DEBOUNCESTATE, 0
	goto    _loop_1
	goto    _action_2

;;;; generated code for Action2
_action_2:

	;; increments DISPLAY in place
	incf DISPLAY, 1

	;; moves DISPLAY to PORTC
	movf  DISPLAY, 0
	movwf PORTC

	goto _loop_1

;;;; generated code for functions
_delay_1ms:
	m_delay_ms D'1'
	return



;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
