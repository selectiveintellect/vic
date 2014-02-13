use lib 'pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

config debounce count = 5;
config debounce delay = 1ms;

Main {
    output_port 'C';
    digital_input_port 'A', 3; # pin 3 is digital, rest analog
    Loop {
        debounce 'A', 3, Action {
            $display++;
            port_value 'C', 0xFF, $display;
        };
    }
}
...

my $output = <<'...';
#include <p16f690.inc>

GLOBAL_VAR_UDATA udata
DISPLAY res 1
SWITCHSTATE res 1
COUNTER res 1

__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

    org 0

_start:
    banksel TRISC
    ;; make all PORTC pins as output
    clrf    TRISC
    ;; make all PORTA pins as input
    movlw   0xFF
    movwf   TRISA
    ;; setting ANSEL bits to 1 enables the the pin to be an analog input
    ;; setting TRISx bits to 0 enables digital output
    ;; hence setting RA3's corresponding bit in ANSEL to 0 makes it a digital input
    ;; the rest of the pins need to be analog input for now
    banksel ANSEL
    movlw   0xF7
    movwf   ANSEL
    banksel PORTA
    ;; clear the PORTC outputs
    clrf    PORTC
    clrf    PORTA
    ;;  set initial state of the switch
    clrf    COUNTER
    clrf    DISPLAY
    movlw   1
    movwf   SWITCHSTATE ; 1 => up and 0 => down
 
_mainloop:
    call    _delay_1ms
    ; has switch state changed to down (bit 0 is 0)
    ; if yes go to switch-state-down
    btfsc   SWITCHSTATE, 0
    goto    _switch_state_up
_switch_state_down:
    clrw
    btfss   PORTA, 3
    incf    COUNTER, W      ; W is 0 here so incremented value is in W
    movwf   COUNTER         ; move W into COUNTER
    goto    _switch_state_check
    
_switch_state_up:
    clrw
    btfsc   PORTA, 3
    incf    COUNTER, W
    movwf   COUNTER
    goto    _switch_state_check

_switch_state_check:
    movf    COUNTER, W  
    xorlw   5
    btfss   STATUS, Z       ; is counter == 5 ?
    goto    _mainloop
    comf    SWITCHSTATE, 1  ; after 5 straight, flip direction
    clrf    COUNTER
    btfss   SWITCHSTATE, 0  ; was it a key-down
    goto    _mainloop       ; take no action
    
_action:
    incf    DISPLAY, 1
    movf    DISPLAY, w
    movwf   PORTC
    goto    _mainloop

_delay_1ms:
    Delay_ms D'1'
    return
...

compiles_ok($input, $output);
