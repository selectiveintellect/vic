use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

pragma adc right_justify = 0;
Main {
    digital_output RC0;
    analog_input RA0;
    # adc_setup clock, channel
    adc_enable 500kHz, AN0;
    Loop {
        adc_read $display;
        delay_ms $display;
        write RC0, 1;
        delay_ms $display;
        write RC0, 0;
        delay 100us;
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

VIC_VAR_DELAY_UDATA udata
VIC_VAR_DELAY   res 3



;;;; generated code for macros
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
    movwf   VIC_VAR_DELAY
_delay_usecs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delay_usecs_loop_0
else
    while usecs_1 < usecs
        nop
usecs_1++
    endw
endif
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
	bcf TRISC, TRISC0
	banksel PORTC
	bcf PORTC, 0

	banksel TRISA
	bsf TRISA, TRISA0
	banksel ANSEL
	movlw 0x01
	movwf ANSEL
	movlw 0x00
	movwf ANSELH
	banksel PORTA

	banksel ADCON1
	movlw B'00000000'
	movwf ADCON1
	banksel ADCON0
	movlw B'00000001'
	movwf ADCON0

;;;; generated code for Loop1
_loop_1:

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
	movwf DISPLAY

	movf DISPLAY, W
	call _delay_wms

	bsf PORTC, 0

	movf DISPLAY, W
	call _delay_wms

	bcf PORTC, 0

	call _delay_100us

	goto _loop_1

;;;; generated code for functions
_delay_100us:
	m_delay_us D'100'
	return

_delay_wms:
	m_delay_wms
	return



;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
