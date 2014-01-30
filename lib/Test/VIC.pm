package Test::VIC;
use strict;
use warnings;

use Test::Builder;
use base qw(Exporter);

our $VERSION = '0.01';
our @EXPORT = qw(
    compiles_ok
    done_testing
);

my $CLASS = __PACKAGE__;
my $Tester = Test::Builder->new;

sub import {
    my $self = shift;
    if (@_) {
        my $package = caller;
        $Tester->exported_to($package);
        $Tester->plan(@_);
    }
    $self->export_to_level(1, $self, $_) foreach @EXPORT;
}

sub compiles_ok {
    my ($input, $output, $msg) = @_;
    unless (defined $input) {
        require Carp;
        Carp::croak("compiles_ok: must pass an input code to compile");
    }
    unless (defined $output) {
        require Carp;
        Carp::croak("compiles_ok: must pass an output code to compare with");
    }
    require VIC;
    my $compiled = VIC::compile($input);
    $compiled =~ s/\s+/ /g;
    $compiled =~ s/, /,/g;
    $output =~ s/;.*//g;
    $output =~ s/\s+/ /g;
    $output =~ s/, /,/g;
    $Tester->is_eq($compiled, $output, $msg);
}

sub done_testing {
    $Tester->done_testing;
}

1;
