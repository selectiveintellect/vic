package VIC::PIC;
use strict;
use warnings;

use Pegex::Base;
extends 'Pegex::Tree';

use VIC::PIC::Any;

use XXX;

has info => undef;
has ast => {};

sub got_uc_select {
    my ($self, $type) = @_;
    $type = lc $type;
    $self->ast->{uc_type} = $type;
    # assume supported type else return
    $self->info(VIC::PIC::Any->new($type));
    die "$type is not a supported chip" unless $self->info->type eq $type;
    $self->ast->{org} = $self->info->org;
    $self->ast->{config} = $self->info->config;
    return;
}

sub got_uc_header {
    my ($self, $list) = @_;
    my $hdr = shift @$list;
    if ($hdr eq 'org') {
        my $org = shift @$list;
        $org = $self->info->org unless defined $org;
        $self->ast->{org} = $org;
    } elsif ($hdr eq 'config') {
        ## TODO: add more options to the default
        $self->ast->{config} = $self->info->config;
        chomp $self->ast->{config}
    }
    return;
}

sub final {
    my ($self, $got) = @_;
    my $ast = $self->ast;
    my $pic = <<"...";
#include <$ast->{uc_type}.inc>

$ast->{config};

org $ast->{org};

...
    return $pic;
}

1;
