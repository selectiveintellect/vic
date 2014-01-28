package VIC::PIC;
use strict;
use warnings;

use Pegex::Base;
extends 'Pegex::Tree';

use VIC::PIC::Any;

use XXX;

has info => undef;
has ast => {};

sub throw_error { shift->parser->throw_error(@_); }

sub got_uc_select {
    my ($self, $type) = @_;
    $type = lc $type;
    $self->ast->{uc_type} = $type;
    # assume supported type else return
    $self->info(VIC::PIC::Any->new($type));
    die "$type is not a supported chip" unless $self->info->type eq $type;
    # set the defaults in case the headers are not provided by the user
    $self->ast->{org} = $self->info->org;
    $self->ast->{config} = $self->info->config;
    $self->ast->{block_stack} = [];
    $self->ast->{block_stack_top} = 0;
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

sub got_block {
    my ($self, $list) = @_;
    $self->flatten($list); # we flatten because we only want the name out
    my $block = shift @$list;
    push @{$self->ast->{block_stack}}, $block;
    $self->ast->{block_stack_top} = scalar @{$self->ast->{block_stack}};
    my $stack = [];
    if ($block eq 'Main') {
        push @$stack, "_start:";
    }
    $self->ast->{$block} = $stack;
}

sub got_end_block {
    my ($self, $list) = @_;
    # we are not capturing anything here
    my $block = pop @{$self->ast->{block_stack}};
    $self->ast->{block_stack_top} = scalar @{$self->ast->{block_stack}};
}

sub final {
    my ($self, $got) = @_;
    my $ast = $self->ast;
    $self->throw_error("Missing '}'") if $self->ast->{block_stack_top} ne 0;
    $self->throw_error("Main not defined") unless defined $self->ast->{Main};
    my $pic = <<"...";
#include <$ast->{uc_type}.inc>

$ast->{config};

org $ast->{org};

$ast->{Main};
$ast->{Loop};
...
    return $pic;
}

1;
