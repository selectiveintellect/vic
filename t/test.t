use Test::More tests => 1;

use lib '../pegex-pm/lib';

my $input = <<'...';
PIC p16f690

set_config

# A Comment

set_org 0

# Hahaha
# Main {
#     output_port 'C', 0
#     Loop {
#         port_value 'C', 1
#         delay 1s
#         port_value 'C', 0
#         delay 1s
#     }
# }
...

my $output = <<'...';
#include <p16F690.inc>

    __config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)


    cblock 0x20
Delay1                   ; Define two file registers for the
Delay2                   ; delay loop
     endc

     org 0

Start:

     bsf       STATUS,RP0          ; select Register Page 1
     bcf       TRISC,0             ; make IO Pin C.0 an output
     bcf       STATUS,RP0          ; back to Register Page 0

MainLoop:

     bsf       PORTC,0             ; turn on LED C0

OndelayLoop:
     decfsz    Delay1,f            ; Waste time.
     goto      OndelayLoop         ; The Inner loop takes 3 instructions per loop * 256 loopss = 768 instructions
     decfsz    Delay2,f            ; The outer loop takes and additional 3 instructions per lap * 256 loops
     goto      OndelayLoop         ; (768+3) * 256 = 197376 instructions / 1M instructions per second = 0.197 sec.
                                   ; call it a two-tenths of a second.

     bcf       PORTC,0             ; Turn off LED C0

OffDelayLoop:
     decfsz    Delay1,f            ; same delay as above
     goto      OffDelayLoop
     decfsz    Delay2,f
     goto      OffDelayLoop

     goto      MainLoop            ; Do it again...

     end
...

use VIC;

is VIC::compile($input), 'fake output'; # $output;
