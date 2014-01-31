package VIC::Command;

use strict;
use warnings;
use Getopt::Long;
use VIC;

sub usage {
    my $usage = << '...';
    Usage: vic [options] <input file>

        -h, --help            This help message
        -o, --output <file>   Writes the compiled syntax to the given output file
        -d, --debug           Dump the compile tree for debugging
...
    die $usage;
}

sub run {
    my ($class, @args) = @_;
    local @ARGV = @args;

    my $debug = 0;
    my $output = '';
    my $help = 0;

    GetOptions(
        "output=s" => \$output,
        "debug" => \$debug,
        "help" => \$help
    ) or usage();
    usage() if $help;

    $VIC::Debug = $debug;

    my $fh;
    if (length $output) {
        open $fh, ">$output" or die "Unable to open $output: $!";
        open STDOUT, ">&", $fh or die "$!";
    }

    print VIC::compile(do {local $/; <>});
}

1;
