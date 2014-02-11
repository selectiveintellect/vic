use lib 'pegex-pm/lib', '../pegex-pm/lib';
use t::TestVIC tests => 1;

my $input = <<'...';
PIC P16F690;

set_config;

# A Comment

set_org 0;

Main {
     output_port 'C', 0; # mark RC0 as output
     port_value 'C', 0, 1;
     hang;
}
...

my $output = <<'...';
#include <p16f690.inc>

__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

org 0

_start:
    ;; turn on PORTC's pin 0 as output
     banksel   TRISC
     bcf       TRISC, TRISC0
     banksel   PORTC
     bsf       PORTC,0
     goto      $
     end
...

compiles_ok($input, $output);
