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
    # assume supported type else return
    $self->info(VIC::PIC::Any->new($type));
    die "$type is not a supported chip" unless $self->info->type eq $type;
    $self->ast->{include} = $self->info->include;
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
        chomp $self->ast->{config};
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
        push @$stack, "_start:\n";
    }
    $self->ast->{$block} = $stack;
    return;
}

sub got_end_block {
    my ($self, $list) = @_;
    # we are not capturing anything here
    my $block = pop @{$self->ast->{block_stack}};
    $self->ast->{block_stack_top} = scalar @{$self->ast->{block_stack}};
    return;
}

sub got_name {
    my ($self, $list) = @_;
    $self->flatten($list);
    return shift(@$list);
}

sub got_instruction {
    my ($self, $list) = @_;
    my $name = shift @$list;
    $self->flatten($list) if $list;
    my @args = @$list if $list;
    $self->throw_error("Unknown instruction $name") unless
        $self->info->can($name);
    my $code = $self->info->$name($name, @args);
    $self->throw_error("Error in statement $name @args") unless $code;
    my $top = $self->ast->{block_stack_top};
    $top = $top - 1 if $top > 0;
    my $block = $self->ast->{block_stack}->[$top];
    push @{$self->ast->{$block}}, $code;
    return;
}

sub got_variable {
    my ($self, $list) = @_;
    return;
}

sub got_number {
    my ($self, $list) = @_;
    # if it is a hexadecimal number we can just convert it to number using int()
    # since hex is returned here as a string
    return int($list);
}

# convert the number to appropriate units
sub got_number_units {
    my ($self, $list) = @_;
    $self->flatten($list);
    my $num = shift @$list;
    my $units = shift @$list || 's';
    $num *= 1 if $units eq 'us';
    $num *= 1000 if $units eq 'ms';
    $num *= 1e6 if $units eq 's';
    return $num;
}

# remove the dumb stuff from the tree
sub got_comment { return; }

sub final {
    my ($self, $got) = @_;
    my $ast = $self->ast;
    $self->throw_error("Missing '}'") if $self->ast->{block_stack_top} ne 0;
    $self->throw_error("Main not defined") unless defined $self->ast->{Main};
    my $pic = <<"...";
#include <$ast->{include}>

$ast->{config}

org $ast->{org}

@{$ast->{Main}}

end
...
    return $pic;
}

1;
