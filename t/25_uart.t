use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

pragma UART baud = 9600; # set baud rate

Main {
    digital_output UART; # set up USART for transmit
    write UART, "Hello World!";
}
...

my $output = <<'...';
;;;; generated code for PIC header file
#include <p16f690.inc>

;;;; generated code for variables

;;;; generated code for macros


	__config (_BOR_OFF & _CP_OFF & _FCMEN_OFF & _IESO_OFF & _INTRC_OSC_CLKOUT & _MCLRE_OFF & _PWRTE_OFF & _WDT_OFF)


	org 0





;;;; generated code for Main
_start:

;;;Desired Baud: 9600
;;;Calculated Baud: 9615.3846
;;;Error: 0.160256%
;;;SPBRG: 25
;;;BRG16: 0
;;;BRGH: 1
	banksel BAUDCTL
	bcf BAUDCTL, BRG16
	banksel TXSTA
	bsf TXSTA, BRGH
	banksel SPBRG
	movlw 0x00
	movwf SPBRGH
	movlw 0x19
	movwf SPBRG

	banksel TXSTA
	bcf TXSTA, SYNC ;; asynchronous operation
	bsf TXSTA, TXEN ;; transmit enable
	banksel RCSTA
	bsf RCSTA, SPEN ;; serial port enable



;;; UNIMPLEMENTED
_end_start:

	goto $	;;;; end of Main

;;;; generated code for functions

;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
