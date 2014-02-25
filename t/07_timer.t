use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

Main {
    digital_output PORTC;
    $display = 0;    
    timer_enable TMR0, 256;
    Loop {
        timer Action {
            $display++;
            write PORTC, $display;
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

;;;; generated code for macros


	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)



	org 0

;;;; generated code for Main
_start:

	banksel TRISC
	clrf TRISC
	banksel PORTC
	clrf PORTC

	clrf DISPLAY

	banksel OPTION_REG
	clrw
	iorlw B'00000111'
	movwf OPTION_REG
	banksel TMR0
	clrf TMR0

;;;; generated code for Loop1
_loop_1:

	btfss INTCON, T0IF
    goto _end_action_2
	bcf INTCON, T0IF
	goto _action_2
_end_action_2:
    goto _loop_1

;;;; generated code for functions
;;;; generated code for Action2
_action_2:

	;; increments DISPLAY in place
	incf DISPLAY, 1

	;; moves DISPLAY to PORTC
	movf  DISPLAY, W
	movwf PORTC
    goto _end_action_2;; from _action_2

;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
