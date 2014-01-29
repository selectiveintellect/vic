package VIC::PIC::Any;
use strict;
use warnings;

use VIC::PIC::P16F690;

# use this to map various PICs to their classes
# allows for the same class to be used for different pics
use constant PICS => {
    P16F690 => 'P16F690',
};

sub new {
    my ($class, $type) = @_;
    my $utype = PICS->{uc $type};
    $class =~ s/::Any/::$utype/g;
    return $class->new(type => lc $utype);
}

1;
