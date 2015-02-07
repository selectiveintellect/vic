use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

pragma UART baud = 9600; # set baud rate

Main {
    setup UART, 9600; # set up USART for transmit
    write UART, "Hello World!";
}
...

my $output = <<'...';
;;;; generated code for PIC header file
#include <p16f690.inc>

;;;; generated code for variables

;;;;;;; USART WRITE VARS ;;;;;;
VIC_VAR_USART_UDATA udata
VIC_VAR_USART_LEN res 1
VIC_VAR_USART_WIDX res 1


;;;; generated code for macros
m_usart_write_byte macro tblentry
    local _usart_write_byte_loop_0
    clrf VIC_VAR_USART_WIDX
_usart_write_byte_loop_0:
    movf VIC_VAR_USART_WIDX, W
    call tblentry
    movwf TXREG
    btfss TXSTA, TRMT
    goto $ - 1
    incf VIC_VAR_USART_WIDX, F
    movf VIC_VAR_USART_WIDX, W
    bcf STATUS, Z
    xorlw VIC_VAR_USART_LEN
    btfss STATUS, Z
    goto _usart_write_byte_loop_0
    endm



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
    ;; asynchronous operation
	bcf TXSTA, SYNC
    ;; transmit enable
	bsf TXSTA, TXEN
	banksel RCSTA
    ;; serial port enable
	bsf RCSTA, SPEN
    ;; continuous receive enable
    bsf RCSTA, CREN
    banksel ANSELH
    bcf ANSELH, ANS11

;;; sending the string 'Hello World!' to UART
;;;; byte array has length 0x0C
    movlw 0x0C
    movwf VIC_VAR_USART_LEN
    m_usart_write_byte _vic_str_00

_end_start:

	goto $	;;;; end of Main

;;;; generated code for functions
	;;storing string 'Hello World!'
_vic_str_00:
	addwf PCL, F
	dt 0x48,0x65,0x6C,0x6C,0x6F,0x20,0x57,0x6F,0x72,0x6C,0x64,0x21

;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
