package VIC::PIC::Functions::Power;
use strict;
use warnings;
our $VERSION = '0.24';
$VERSION = eval $VERSION;
use Carp;
use POSIX ();
use Moo::Role;

sub sleep {
    my $self = shift;
    return << "...";
\tsleep
...
}

1;
__END__
