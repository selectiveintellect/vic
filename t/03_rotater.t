use lib 'pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

Main {
    output_port 'C', 0;
    $display = 0x08; # create a 8-bit register by checking size
    Loop {
        port_value 'C', 0, $display;
        delay 1s;
        # improve this depiction
        # circular rotate right by 1 bit
        ror $display, 1;
    }
}
...

my $output = <<'...';
#include <p16f690.inc>

__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

org 0

_start:
    ;; turn on PORTC's pin 0 as output
     end
...

compiles_ok($input, $output);
