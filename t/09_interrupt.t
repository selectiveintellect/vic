use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

config debounce count = 2;
config debounce delay = 1ms;
config adc right_justify = 0;

Main {
    digital_output PORTC;
    analog_input RA0;
    digital_input RA3;
    adc_enable 500kHz, AN0;
    $display = 0x08; # create a 8-bit register
    $dirxn = 0;
    timer_enable TMR0, 256, ISR {#set the interrupt service routine
        adc_read $userval;
        $userval += 100;
    };
    Loop {
        write PORTC, $display;
        delay_ms $userval;
        debounce RA3, Action {
            $dirxn = !$dirxn;
        };
        if $dirxn == 1, {
            rol $display, 1;
        }, {
            ror $display, 1;
        };
    }
}
...

my $output = << '...';
;;;; generated code for PIC header file
#include <p16f690.inc>

;;;; generated code for variables
GLOBAL_VAR_UDATA udata
DIRXN res 1
DISPLAY res 1
USERVAL res 1

;;;;;; DEBOUNCE VARIABLES ;;;;;;;

DEBOUNCE_VAR_IDATA idata
;; initialize state to 1
DEBOUNCESTATE db 0x01
;; initialize counter to 0
DEBOUNCECOUNTER db 0x00



;;;;;; DELAY FUNCTIONS ;;;;;;;

DELAY_VAR_UDATA udata
DELAY_VAR   res 3



cblock 0x70 ;; unbanked RAM
ISR_STATUS
ISR_W
endc


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

m_delay_wms macro
    local _delayw_msecs_loop_0, _delayw_msecs_loop_1
    movwf   DELAY_VAR + 1
_delayw_msecs_loop_1:
    clrf   DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delayw_msecs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delayw_msecs_loop_0
    decfsz  DELAY_VAR + 1, F
    goto    _delayw_msecs_loop_1
    endm



	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)



	org 0

	goto _start
	nop
	nop
	nop

	org 4
ISR:
_isr_entry:
	movwf ISR_W
	movf STATUS, W
	movwf ISR_STATUS

_isr_timer:
	btfss INTCON, T0IF
	goto _end_isr_1
	bcf   INTCON, T0IF
	goto _isr_1
_end_isr_1:

	goto _isr_exit

;;;; generated code for ISR
_isr_1:

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

	goto _end_isr_1;; go back to end of conditional

_isr_exit:
	movf ISR_STATUS, W
	movwf STATUS
	swapf ISR_W, F
	swapf ISR_W, W
	retfie



;;;; generated code for Main
_start:

	banksel TRISC
	clrf TRISC
	banksel PORTC
	clrf PORTC

	banksel TRISA
	bsf TRISA, TRISA0
	banksel ANSEL
	movlw 0x01
	movwf ANSEL
	movlw 0x00
	movwf ANSELH
	banksel PORTA

	banksel TRISA
	bcf TRISA, TRISA3
	banksel ANSEL
	movlw 0xFF
	movwf ANSEL
	movlw 0xFF
	movwf ANSELH
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

;; timer prescaling
	banksel OPTION_REG
	clrw
	iorlw B'00000111'
	movwf OPTION_REG

;; enable interrupt servicing
	banksel INTCON
	clrf INTCON
	bsf INTCON, GIE
	bsf INTCON, T0IE


;; clear the timer
	banksel TMR0
	clrf TMR0


;;;; generated code for Loop1
_loop_2:

	;; moves DISPLAY to PORTC
	movf  DISPLAY, W
	movwf PORTC

	movf USERVAL, W
	call _delay_wms

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
	xorlw   2
	;; is counter == 2 ?
	btfss   STATUS, Z
	goto    _end_action_3
	;; after 2 straight, flip direction
	comf    DEBOUNCESTATE, 1
	clrf    DEBOUNCECOUNTER
	;; was it a key-down
	btfss   DEBOUNCESTATE, 0
	goto    _end_action_3
	goto    _action_3
_end_action_3:


	movf DIRXN, W
	xorlw 1
	btfss STATUS, Z ;; DIRXN == 1 ?
	goto _false_5
	goto _true_4
_end_conditional_0:


	goto _loop_2

;;;; generated code for functions
;;;; generated code for Action2
_action_3:

	;; clrw -- leftover from old code

;; generate code for !DIRXN
	comf DIRXN, W
	btfsc STATUS, Z
	movlw 1

	movwf DIRXN

	goto _end_action_3;; go back to end of conditional

_delay_1ms:
	m_delay_ms D'1'
	return

_delay_wms:
	m_delay_wms
	return

;;;; generated code for False2
_false_5:

	bcf STATUS, C
	rrf DISPLAY, 1
	btfsc STATUS, C
	bsf DISPLAY, 7

	goto _end_conditional_0;; go back to end of conditional

;;;; generated code for True2
_true_4:

	bcf STATUS, C
	rlf DISPLAY, 1
	btfsc STATUS, C
	bsf DISPLAY, 0

	goto _end_conditional_0;; go back to end of conditional



;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
