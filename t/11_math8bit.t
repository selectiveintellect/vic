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
    $var3 = $var2 * $var1;
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

;;;;;; VIC_VAR_MULTIPLY VARIABLES ;;;;;;;

VIC_VAR_MULTIPLY_UDATA udata
VIC_VAR_MULTIPLICAND res 2
VIC_VAR_MULTIPLIER res 2
VIC_VAR_PRODUCT res 2


;;;; generated code for macros
;;;;;; multiply v1 and v2 using shifting. multiplication of 8-bit values is done
;;;;;; using 16-bit variables. v1 is a variable and v2 is a constant
m_multiply_1 macro v1, v2
    local _m_multiply1_loop_0, _m_multiply1_skip
    movf v1, W
    movwf VIC_VAR_MULTIPLIER
    clrf VIC_VAR_MULTIPLIER + 1
    movlw v2, W
    movwf VIC_VAR_MULTIPLICAND
    clrf VIC_VAR_MULTIPLICAND + 1
    clrf VIC_VAR_PRODUCT
    clrf VIC_VAR_PRODUCT + 1
_m_multiply1_loop_0:
    rrf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, C
    goto _m_multiply1_skip
    movf VIC_VAR_MULTIPLIER + 1, W
    addwf VIC_VAR_PRODUCT + 1, F
    movf VIC_VAR_MULTIPLIER, W
    addwf VIC_VAR_PRODUCT, F
    btfsc STATUS, C
    incf VIC_VAR_PRODUCT + 1, F
_m_multiply1_skip:
    bcf STATUS, C
    rlf VIC_VAR_MULTIPLIER, F
    rlf VIC_VAR_MULTIPLIER + 1, F
    movf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, Z
    goto _m_multiply1_loop_0
    movf VIC_VAR_PRODUCT, W
    endm
;;;;;; multiply v1 and v2 using shifting. multiplication of 8-bit values is done
;;;;;; using 16-bit variables. v1 and v2 are variables
m_multiply_2 macro v1, v2
    local _m_multiply2_loop_0, _m_multiply2_skip
    movf v1, W
    movwf VIC_VAR_MULTIPLIER
    clrf VIC_VAR_MULTIPLIER + 1
    movf v2, W
    movwf VIC_VAR_MULTIPLICAND
    clrf VIC_VAR_MULTIPLICAND + 1
    clrf VIC_VAR_PRODUCT
    clrf VIC_VAR_PRODUCT + 1
_m_multiply2_loop_0:
    rrf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, C
    goto _m_multiply2_skip
    movf VIC_VAR_MULTIPLIER + 1, W
    addwf VIC_VAR_PRODUCT + 1, F
    movf VIC_VAR_MULTIPLIER, W
    addwf VIC_VAR_PRODUCT, F
    btfsc STATUS, C
    incf VIC_VAR_PRODUCT + 1, F
_m_multiply2_skip:
    bcf STATUS, C
    rlf VIC_VAR_MULTIPLIER, F
    rlf VIC_VAR_MULTIPLIER + 1, F
    movf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, Z
    goto _m_multiply2_loop_0
    movf VIC_VAR_PRODUCT, W
    endm



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

	;; perform VAR2 * VAR1 without affecting either
	m_multiply_2 VAR2, VAR1

	movwf VAR3

	;; decrements VAR3 in place
	;; decrement byte[0]
	decf VAR3, F

	;; increments VAR3 in place
	;; increment byte[0]
	incf VAR3, F


;;;; generated code for functions


;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
