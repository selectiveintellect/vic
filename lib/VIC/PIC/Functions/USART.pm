package VIC::PIC::Functions::USART;
use strict;
use warnings;
our $VERSION = '0.23';
$VERSION = eval $VERSION;
use Carp;
use POSIX ();
use Moo::Role;

sub usart_setup {
    my ($self, $io, $ad, $outp) = @_;
    if ($ad =~ /analog/i) {
        carp "$outp cannot have analog I/O";
        return;
    }
}

sub usart_write {
    my ($self, $port, $data) = @_;
}

1;
__END__
