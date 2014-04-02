use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

config variable bits = 8;

Main {
    $var1 = 12345;
    $var2 = 113;
    $var3 = $var2 + $var1;
    $var3 = $var2 - $var1;
    #$var3 = $var2 * $var1;
    #$var3 = $var2 / $var1;
    #$var3 = $var2 % $var1;
    --$var3;
    ++$var3;
    #$var4 = 64;
    # sqrt is a modifier
    #$var3 = sqrt $var4;
    #$var5 = ($var1 + (($var3 * ($var4 + $var7) + 5) + $var2));
}
...

my $output = << '...';
;;;; generated code for PIC header file
#include <p16f690.inc>

;;;; generated code for variables
GLOBAL_VAR_UDATA udata
VAR1 res 1
VAR2 res 1
VAR3 res 1

;;;; generated code for macros


	__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)



	org 0



;;;; generated code for Main
_start:

	;; moves 12345 (0x3039) to VAR1
	;; 12345 doesn't fit in 8-bits. Using 57 (0x39)
	movlw 0x39
	movwf VAR1

	;; moves 113 (0x71) to VAR2
	movlw 0x71
	movwf VAR2

	;; add VAR2 and VAR1 without affecting either
	movf VAR2, W
	addwf VAR1, W

	movwf VAR3

	;; perform VAR2 - VAR1 without affecting either
	movf VAR1, W
	subwf VAR2, W

	movwf VAR3

	;; decrements VAR3 in place
	;; decrement byte[0]
	decf VAR3, W

	;; increments VAR3 in place
	;; increment byte[0]
	incf VAR3, F


;;;; generated code for functions


;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
