package VIC::PIC::P16F690;
use strict;
use warnings;
use Pegex::Base; # use this instead of Mo

has type => 'p16f690';

has org => 0;

has config => <<'...';
__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF &
            _BOR_OFF & _IESO_OFF & _FCMEN_OFF)
...

1;
