package VIC::PIC::Any;
use strict;
use warnings;

use VIC::PIC::P16F690;

sub new {
    my ($class, $type) = @_;
    my $utype = uc $type;
    $class =~ s/::Any/::$utype/g;
    return $class->new;
}

1;
