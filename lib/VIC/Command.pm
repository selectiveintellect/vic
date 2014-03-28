package VIC::Command;

use strict;
use warnings;
use Getopt::Long;
use VIC;

our $VERSION = '0.05';
$VERSION = eval $VERSION;

sub usage {
    my $usage = << '...';
    Usage: vic [options] <input file>

        -h, --help            This help message
        -V, --version         Version number
        -p, --pic <PIC>       Use this PIC choice instead of the one in the code
        -o, --output <file>   Writes the compiled syntax to the given output file
        -d, --debug           Dump the compile tree for debugging
        -i, --intermediate    Inline the intermediate code with the output
...
    die $usage;
}

sub version {
    my $txt = << "...";
VIC version $VERSION
...
    die $txt;
}

sub run {
    my ($class, @args) = @_;
    local @ARGV = @args;

    my $debug = 0;
    my $output = '';
    my $help = 0;
    my $pic = undef;
    my $intermediate = undef;
    my $version = 0;

    GetOptions(
        "output=s" => \$output,
        "debug" => \$debug,
        "help" => \$help,
        "pic=s" => \$pic,
        "intermediate" => \$intermediate,
        "version" => \$version,
    ) or usage();
    usage() if $help;
    version() if $version;

    $VIC::Debug = $debug;
    $VIC::Intermediate = $intermediate;

    my $fh;
    if (length $output) {
        open $fh, ">$output" or die "Unable to open $output: $!";
        open STDOUT, ">&", $fh or die "$!";
    }

    print VIC::compile(do {local $/; <>}, $pic);
}

1;

=encoding utf8

=head1 NAME

VIC::Command

=head1 SYNOPSIS

The command-line tool for compiling VIC files.

=head1 DESCRIPTION

To view all the options run 
    $ vic -h


=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
