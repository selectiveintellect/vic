package VIC::PIC::Base;
use strict;
use warnings;

our $VERSION = '0.16';
$VERSION = eval $VERSION;

use Carp;
use Moo;
use VIC::PIC::Roles; # load all the roles
use namespace::clean;

sub doesrole {
    my $a = $_[0]->does('VIC::PIC::Roles::' . $_[1]);
    carp ref($_[0]) . " does not do role $_[1]" unless $a;
    return $a;
}

sub doesroles {
    my $self = shift;
    foreach (@_) {
        return unless $self->doesrole($_);
    }
    return 1;
}

has chip_config => (is => 'ro', default => sub { {} });

1;
