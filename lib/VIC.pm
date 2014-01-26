package VIC;

use Pegex::Parser;
use VIC::Grammar;
use VIC::PIC;

sub compile {
    my ($input) = @_;

    my $parser = Pegex::Parser->new(
        grammar => VIC::Grammar->new,
        receiver => VIC::PIC->new,
    );

    $parser->parse($input);

    return $parser->receiver->data;
}

1;
