package VIC::PIC;
use strict;
use warnings;

use Pegex::Base;
extends 'Pegex::Tree';

use XXX;

has ast => {}; # Mo
# has ast => (is => 'ro', default => {}); #Moose

sub got_uc_type {
    my ($self, $type) = @_;
    $self->ast->{uc_type} = lc $type;
    return;
}

sub got_uc_header {
    my ($self, $list) = @_;
    $self->ast->{uc_org} = shift @$list;
    return;
}

sub final {
    my ($self) = @_;
    my $ast = $self->ast;
    my $pic = <<"...";
#include <$ast->{uc_type}.inc>
$ast->{uc_org};
...
    return $pic;
}

1;
