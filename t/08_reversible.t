use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

pragma debounce count = 2;
pragma debounce delay = 1ms;
pragma adc right_justify = 0;

Main {
    digital_output PORTC;
    digital_input RA3;
    analog_input RA0;
    # adc_enable clock, channel
    adc_enable 500kHz, AN0;
    $display = 0x08; # create a 8-bit register
    $dirxn = FALSE;
    Loop {
        write PORTC, $display;
        adc_read $userval;
        $userval += 100;
        delay_ms $userval;
        debounce RA3, Action {
            $dirxn = !$dirxn;
        };
        if $dirxn == TRUE {
            rol $display, 1;
        } else {
            ror $display, 1;
        };
    }
}
...

my $output = <<'...';
#include <p16f690.inc>

;;;; generated code for variables
GLOBAL_VAR_UDATA udata
DIRXN res 1
DISPLAY res 1
USERVAL res 1

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

m_delay_wms macro
    local _delayw_msecs_loop_0, _delayw_msecs_loop_1
    movwf   VIC_VAR_DELAY + 1
_delayw_msecs_loop_1:
    clrf   VIC_VAR_DELAY   ;; set to 0 which gets decremented to 0xFF
_delayw_msecs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delayw_msecs_loop_0
    decfsz  VIC_VAR_DELAY + 1, F
    goto    _delayw_msecs_loop_1
    endm



	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)



	org 0

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
	bcf TRISA, TRISA3
	banksel PORTA

	banksel TRISA
	bsf TRISA, TRISA0
	banksel ANSEL
    bsf ANSEL, ANS0
	banksel PORTA

	banksel ADCON1
	movlw B'00000000'
	movwf ADCON1
	banksel ADCON0
	movlw B'00000001'
	movwf ADCON0

	;; moves 8 to DISPLAY
	movlw 0x08
	movwf DISPLAY

	clrf DIRXN

;;;; generated code for Loop1
_loop_1:

	;; moves DISPLAY to PORTC
	movf  DISPLAY, W
	movwf PORTC

	;;;delay 5us
	nop
	nop
	nop
	nop
	nop
	bsf ADCON0, GO
	btfss ADCON0, GO
	goto $ - 1
	movf ADRESH, W
	movwf USERVAL

	;;moves 100 to W
	movlw 0x64
	addwf USERVAL, F

	movf USERVAL, W
	call _delay_wms

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
	xorlw   0x02
	;; is counter == 2 ?
	btfss   STATUS, Z
	goto    _end_action_2
	;; after 2 straight, flip direction
	comf    VIC_VAR_DEBOUNCESTATE, 1
	clrf    VIC_VAR_DEBOUNCECOUNTER
	;; was it a key-down
	btfss   VIC_VAR_DEBOUNCESTATE, 0
	goto    _end_action_2
	goto    _action_2
_end_action_2:

_start_conditional_0:
    bcf STATUS, Z
	movf DIRXN, W
	xorlw 0x01
	btfss STATUS, Z ;; DIRXN == 1 ?
	goto _false_4
	goto _true_3
_end_conditional_0:


	goto _loop_1
_end_loop_1:
_end_start:
    goto $

;;;; generated code for functions
;;;; generated code for Action2
_action_2:

	;clrw -- leftover from old code generator

;; generate code for !DIRXN
	comf DIRXN, W
	btfsc STATUS, Z
	movlw 1

	movwf DIRXN

	goto _end_action_2;; go back to end of conditional

_delay_1ms:
	m_delay_ms D'1'
	return

_delay_wms:
	m_delay_wms
	return

;;;; generated code for False2
_false_4:

	bcf STATUS, C
	rrf DISPLAY, 1
	btfsc STATUS, C
	bsf DISPLAY, 7

	goto _end_conditional_0;; go back to end of conditional

;;;; generated code for True2
_true_3:

	bcf STATUS, C
	rlf DISPLAY, 1
	btfsc STATUS, C
	bsf DISPLAY, 0

	goto _end_conditional_0;; go back to end of conditional



;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
