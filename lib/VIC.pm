package VIC;
use strict;
use warnings;

use Pegex::Parser;
use VIC::Grammar;
use VIC::PIC;

use XXX;

sub compile {
    my ($input) = @_;

    my $parser = Pegex::Parser->new(
        grammar => VIC::Grammar->new,
        receiver => VIC::PIC->new,
        debug => 1,
    );

    $parser->parse($input);
}

1;
