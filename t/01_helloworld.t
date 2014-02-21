use lib 'ext/pegex-pm/lib';
use t::TestVIC tests => 1, debug => 0;

my $input = <<'...';
PIC P16F690;

# A Comment

Main { # set the Main function
     digital_output RC0; # mark pin RC0 as output
     write RC0, 1; # write the value 1 to RC0
     hang;
} # end the Main function
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
     bcf       PORTC, 0
     bsf       PORTC, 0
     goto      $
     end
...

compiles_ok($input, $output);
