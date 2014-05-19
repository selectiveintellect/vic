package t::TestVIC;
use strict;
use warnings;
#use lib '../pegex-pm/lib';

use Carp;
use Test::Builder;
use VIC;
use base qw(Exporter);

our @EXPORT = qw(
    compiles_ok
    compile_fails_ok
);

my $CLASS = __PACKAGE__;
my $Tester = Test::Builder->new;

sub import {
    my $self = shift;
    if (@_) {
        my %hh = @_;
        $VIC::Debug = $hh{debug} if exists $hh{debug};
        my $package = caller;
        $Tester->exported_to($package);
        $Tester->plan(@_);
    }
    $self->export_to_level(1, $self, $_) foreach @EXPORT;
}

sub sanitize {
    my $c = shift;
    $c =~ s/;.*[\r\n]//gm;
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
        croak("compiles_ok: must pass an input code to compile");
    }
    unless (defined $output) {
        croak("compiles_ok: must pass an output code to compare with");
    }
    my $compiled = VIC::compile($input);
    $compiled = sanitize($compiled);
    $output = sanitize($output);
    my $ok = $Tester->is_eq($compiled, $output, $msg);
    return if $ok;
    ## show the diffs
    $compiled =~ s/\s+//gm;
    $output =~ s/\s+//gm;
    my @c0 = split//,$compiled;
    my @c1 = split//,$output;
    my $count = 0;
    $Tester->diag("Count of characters: $#c0 $#c1\n");
    for (my $i = 0; $i < $#c0 and $i < $#c1; $i++) {
        $Tester->diag("Character $i: $c0[$i] != $c1[$i]"), $count++ if $c0[$i] ne $c1[$i];
        last if $count > 5;
    }
}

sub compile_fails_ok {
    my ($input, $msg) = @_;
    unless (defined $input) {
        croak("compile_fails_ok: must pass an input code to compile");
    }
    eval { VIC::compile($input); };
    $Tester->ok($@, $@);
}

1;

=encoding utf8

=head1 NAME

t::TestVIC;

=head1 SYNOPSIS

A test class for handling VIC testing

=head1 DESCRIPTION

=over

=item B<compiles_ok $input, $output>

This function takes the input VIC code, and the expected assembly code and
checks whether the VIC code compiles into the assembly code.

=item B<compile_fails_ok $input>

This function takes the input VIC code and checks whether the VIC code fails
to compile into assembly code.

=back

=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
