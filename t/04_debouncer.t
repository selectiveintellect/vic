use lib 'pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

config switch_debounce_count = 5;
config switch_debounce_delay = 1ms;

Main {
    output_port 'C';
    analog_input_port 'A'; # all pins
    digital_port 'A', 3; # pin 3 is digital, rest analog
    Loop {
        switch 'A', 3, on_press {
            $value++;
            port_value 'C', 0xFF, $value;
        };
    }
}
...

my $output = <<'...';
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
    ;; ANSEL has to be initialized to configure an analog channel as digital
    ;; input. we want pin RA3 to be configured as digital input
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
