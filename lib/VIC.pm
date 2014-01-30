package VIC;
use strict;
use warnings;

use Pegex::Parser;
use VIC::Grammar;
use VIC::PIC;

use XXX;

our $Debug = 0;

sub compile {
    my ($input) = @_;

    my $parser = Pegex::Parser->new(
        grammar => VIC::Grammar->new,
        receiver => VIC::PIC->new,
        debug => $Debug,
    );

    $parser->parse($input);
}

1;
