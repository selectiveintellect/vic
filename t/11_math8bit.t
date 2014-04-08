use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

pragma variable bits = 8;
pragma variable export;

Main {
    $var1 = 12345;
    $var2 = 113;
    $var3 = $var2 + $var1;
    $var3 = $var2 - $var1;
    $var3 = $var2 * $var1;
    $var2 = $var2 * 5;
    $var3 = $var2 / $var1;
    $var3 = $var2 % $var1;
    --$var3;
    ++$var3;
    $var4 = 64;
    $var4 -= $var1;
    $var3 *= 3;
    $var2 /= 5;
    $var4 %= $var2;
    $var4 = 64;
    $var4 ^= 0xFF;
    $var4 |= 0x80;
    $var4 &= 0xAA;
    # sqrt is a modifier
    #$var3 = sqrt $var4;
    #$var5 = ($var1 + (($var3 * ($var4 + $var7) + 5) + $var2));
    hang;
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
VAR4 res 1
    global VAR1, VAR2, VAR3, VAR4

;;;;;; VIC_VAR_DIVIDE VARIABLES ;;;;;;;

VIC_VAR_DIVIDE_UDATA udata
VIC_VAR_DIVISOR res 2
VIC_VAR_REMAINDER res 2
VIC_VAR_QUOTIENT res 2
VIC_VAR_BITSHIFT res 2
VIC_VAR_DIVTEMP res 1


;;;;;; VIC_VAR_MULTIPLY VARIABLES ;;;;;;;

VIC_VAR_MULTIPLY_UDATA udata
VIC_VAR_MULTIPLICAND res 2
VIC_VAR_MULTIPLIER res 2
VIC_VAR_PRODUCT res 2


;;;; generated code for macros
;;;;;; Taken from Microchip PIC examples.
m_divide_internal macro
    local _m_divide_shiftuploop, _m_divide_loop, _m_divide_shift
    clrf VIC_VAR_QUOTIENT
    clrf VIC_VAR_QUOTIENT + 1
    clrf VIC_VAR_BITSHIFT + 1
    movlw 0x01
    movwf VIC_VAR_BITSHIFT
_m_divide_shiftuploop:
    bcf STATUS, C
    rlf VIC_VAR_DIVISOR, F
    rlf VIC_VAR_DIVISOR + 1, F
    bcf STATUS, C
    rlf VIC_VAR_BITSHIFT, F
    rlf VIC_VAR_BITSHIFT + 1, F
    btfss VIC_VAR_DIVISOR + 1, 7
    goto _m_divide_shiftuploop
_m_divide_loop:
    movf VIC_VAR_DIVISOR, W
    subwf VIC_VAR_REMAINDER, W
    movwf VIC_VAR_DIVTEMP
    movf VIC_VAR_DIVISOR + 1, W
    btfss STATUS, C
    addlw 0x01
    subwf VIC_VAR_REMAINDER + 1, W
    btfss STATUS, C
    goto _m_divide_shift
    movwf VIC_VAR_REMAINDER + 1
    movf VIC_VAR_DIVTEMP, W
    movwf VIC_VAR_REMAINDER
    movf VIC_VAR_BITSHIFT + 1, W
    addwf VIC_VAR_QUOTIENT + 1, F
    movf VIC_VAR_BITSHIFT, W
    addwf VIC_VAR_QUOTIENT, F
_m_divide_shift:
    bcf STATUS, C
    rrf VIC_VAR_DIVISOR + 1, F
    rrf VIC_VAR_DIVISOR, F
    bcf STATUS, C
    rrf VIC_VAR_BITSHIFT + 1, F
    rrf VIC_VAR_BITSHIFT, F
    btfss STATUS, C
    goto _m_divide_loop
    endm
;;;;;; v1 and v2 are variables
m_divide_2 macro v1, v2
    movf v1, W
    movwf VIC_VAR_REMAINDER
    clrf VIC_VAR_REMAINDER + 1
    movf v2, W
    movwf VIC_VAR_DIVISOR
    clrf VIC_VAR_DIVISOR + 1
    m_divide_internal
    movf VIC_VAR_QUOTIENT, W
    endm
;;;;;; v1 is literal and v2 is variable
m_divide_1a macro v1, v2
    movlw v1
    movwf VIC_VAR_REMAINDER
    clrf VIC_VAR_REMAINDER + 1
    movf v2, W
    movwf VIC_VAR_DIVISOR
    clrf VIC_VAR_DIVISOR + 1
    m_divide_internal
    movf VIC_VAR_QUOTIENT, W
    endm
;;;;;;; v2 is literal and v1 is variable
m_divide_1b macro v1, v2
    movf v1, W
    movwf VIC_VAR_REMAINDER
    clrf VIC_VAR_REMAINDER + 1
    movlw v2
    movwf VIC_VAR_DIVISOR
    clrf VIC_VAR_DIVISOR + 1
    m_divide_internal
    movf VIC_VAR_QUOTIENT, W
    endm
m_mod_2 macro v1, v2
    m_divide_2 v1, v2
    movf VIC_VAR_REMAINDER, W
    endm
;;;;;; v1 is literal and v2 is variable
m_mod_1a macro v1, v2
    m_divide_1a v1, v2
    movf VIC_VAR_REMAINDER, W
    endm
;;;;;;; v2 is literal and v1 is variable
m_mod_1b macro v1, v2
    m_divide_1b v1, v2
    movf VIC_VAR_REMAINDER, W
    endm

;;;;;; Taken from Microchip PIC examples.
;;;;;; multiply v1 and v2 using shifting. multiplication of 8-bit values is done
;;;;;; using 16-bit variables. v1 is a variable and v2 is a constant
m_multiply_internal macro
    local _m_multiply_loop_0, _m_multiply_skip
    clrf VIC_VAR_PRODUCT
    clrf VIC_VAR_PRODUCT + 1
_m_multiply_loop_0:
    rrf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, C
    goto _m_multiply_skip
    movf VIC_VAR_MULTIPLIER + 1, W
    addwf VIC_VAR_PRODUCT + 1, F
    movf VIC_VAR_MULTIPLIER, W
    addwf VIC_VAR_PRODUCT, F
    btfsc STATUS, C
    incf VIC_VAR_PRODUCT + 1, F
_m_multiply_skip:
    bcf STATUS, C
    rlf VIC_VAR_MULTIPLIER, F
    rlf VIC_VAR_MULTIPLIER + 1, F
    movf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, Z
    goto _m_multiply_loop_0
    movf VIC_VAR_PRODUCT, W
    endm
;;;;;;; v1 is variable and v2 is literal
m_multiply_1 macro v1, v2
    movf v1, W
    movwf VIC_VAR_MULTIPLIER
    clrf VIC_VAR_MULTIPLIER + 1
    movlw v2
    movwf VIC_VAR_MULTIPLICAND
    clrf VIC_VAR_MULTIPLICAND + 1
    m_multiply_internal
    endm
;;;;;; multiply v1 and v2 using shifting. multiplication of 8-bit values is done
;;;;;; using 16-bit variables. v1 and v2 are variables
m_multiply_2 macro v1, v2
    movf v1, W
    movwf VIC_VAR_MULTIPLIER
    clrf VIC_VAR_MULTIPLIER + 1
    movf v2, W
    movwf VIC_VAR_MULTIPLICAND
    clrf VIC_VAR_MULTIPLICAND + 1
    m_multiply_internal
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

	;; perform VAR2 * 0x05 without affecting VAR2
	m_multiply_1 VAR2, 0x05

	movwf VAR2

	;; perform VAR2 / VAR1 without affecting either
	m_divide_2 VAR2, VAR1

	movwf VAR3

	;; perform VAR2 / VAR1 without affecting either
	m_mod_2 VAR2, VAR1

	movwf VAR3

	;; decrements VAR3 in place
	;; decrement byte[0]
	decf VAR3, F

	;; increments VAR3 in place
	;; increment byte[0]
	incf VAR3, F

    ;; moves 64 (0x40) to VAR4
    movlw 0x40
    movwf VAR4

    ;;moves VAR1 to W and subtracts from VAR4
    movf VAR1, W
    subwf VAR4, W
    movwf VAR4
    ;; perform VAR3 * 0x03 without affecting VAR3
    m_multiply_1 VAR3, 0x03
    movwf VAR3

    ;; SET::DIV_ASSIGN::var2::5
    ;; perform VAR2 / 0x05 without affecting VAR2
    m_divide_1b VAR2, 0x05
    movwf VAR2

    ;; SET::MOD_ASSIGN::var4::var2
    ;; perform VAR4 / VAR2 without affecting either
    m_mod_2 VAR4, VAR2
    movwf VAR4


    ;; moves 64 (0x40) to VAR4
    movlw 0x40
    movwf VAR4

    ;; perform VAR4 ^ 0xFF and move into W
    movlw 0xFF
    xorwf VAR4, W
    movwf VAR4

    ;; perform VAR4 | 0x80 and move into W
    movlw 0x80
    iorwf VAR4, W
    movwf VAR4

    ;; perform VAR4 & 0xAA and move into W
    movlw 0xAA
    andwf VAR4, W
    movwf VAR4

    goto $

;;;; generated code for functions


;;;; generated code for end-of-file
	end
...

compiles_ok($input, $output);
