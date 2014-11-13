package VIC::PIC::Functions::Chip;
use strict;
use warnings;
use Moo::Role;

##TODO: allow adjusting of this based on user input. for now fixed to this
#string
sub chip_config {
    return <<"...";
        __config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)
...
}

1;
__END__
