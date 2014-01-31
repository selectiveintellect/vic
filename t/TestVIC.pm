package t::TestVIC;
use strict;
use warnings;

use Test::Builder;
use VIC;
use base qw(Exporter);

our @EXPORT = qw(
    compiles_ok
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

sub sanitize {
    my $c = shift;
    $c =~ s/;.*//gm;
    $c =~ s/, /,/gm;
    $c =~ s/[\r\n]+/\n/gm;
    $c =~ s/[\r\n]\s+/\n/gm;
    $c =~ s/\s+[\r\n]/\n/gm;
    $c =~ s/ +$//gm;
    $c =~ s/[ ]+/ /gm;
    return $c;
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
    my $compiled = VIC::compile($input);
    $compiled = sanitize($compiled);
    $output = sanitize($output);
    $Tester->is_eq($compiled, $output, $msg);
    ## show the diffs
    $compiled =~ s/\s+//gm;
    $output =~ s/\s+//gm;
    my @c0 = split//,$compiled;
    my @c1 = split//,$output;
    for (my $i = 0; $i < $#c0; $i++) {
        $Tester->diag("Character $i: $c0[$i] != $c1[$i]") if $c0[$i] ne $c1[$i];
    }
}

1;
