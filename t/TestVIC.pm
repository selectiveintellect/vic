package t::TestVIC;
use strict;
use warnings;

use Carp;
use File::Which qw(which);
use Test::Builder;
use VIC;
use base qw(Exporter);

our @EXPORT = qw(
    compiles_ok
    compile_fails_ok
    compiles_asm_ok
    done_testing
    subtest
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
        $Tester->plan(%hh);
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


sub compiles_asm_ok {
    my ($input, $chip) = @_;
    unless (defined $input) {
        croak("compiles_asm_ok: must pass an input code to compile");
    }
    return $Tester->skip('Only for developer. Set $ENV{TEST_GPASM} to run.') unless defined $ENV{TEST_GPASM};
    return $Tester->skip("gputils(gpasm) is not installed") unless -e which('gpasm');
    return $Tester->skip("gputils(gplink) is not installed") unless -e which('gplink');
    my $compiled = VIC::compile($input, $chip);
    my $output = File::Spec->catfile(File::Spec->tmpdir, "$chip.asm");
    my $fh;
    open $fh, ">$output" or die "Unable to open $output: $!";
    print $fh $compiled, "\n";
    close $fh;

    my $ok = $Tester->ok(system("gpasm -p $chip -c $output -o $output.o") == 0);
    if ($ok) {
        ## create hex file now to check linking
        $ok &= $Tester->ok(system("gplink -q -m $output.o -o $output.hex ") == 0);
        map(unlink, <$output.*>, $output) if $ok;
    }
    return $ok;
}

sub done_testing { $Tester->done_testing(); }

sub subtest { $Tester->subtest(@_); }

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
