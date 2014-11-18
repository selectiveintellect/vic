package VIC::Command;

use strict;
use warnings;
use Getopt::Long;
use File::Spec;
use File::Which qw(which);
use VIC;

our $VERSION = '0.15';
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
        --list-chips          List the supported microcontroller chips
        --list-simulators     List the supported simulators
        --supports <PIC>      Checks if the given PIC is supported
        --list-features <PIC> Lists the features of the PIC
        --no-hex              Does not generate the hex file using gputils

...
    die $usage;
}

sub version {
    my $txt = << "...";
VIC version $VERSION
...
    die $txt;
}

sub print_chips {
    my @chips = VIC::supported_chips();
    my $ctxt = join("\n", @chips);
    my $txt = << "...";
VIC supports the following microcontroller chips:
$ctxt

...
    print $txt;
}

sub print_sims {
    my @sims = VIC::supported_simulators();
    my $stxt = join("\n", @sims);
    my $txt = << "...";
VIC supports the following simulators:
$stxt

...
    print $txt;
}

sub check_support {
    my $chip = shift;
    my $flag = VIC::is_chip_supported($chip);
    die "VIC does not support '$chip'\n" unless $flag;
    print "VIC supports '$chip'\n" if $flag;
}

sub list_chip_features {
    my $chip = shift;
    check_support($chip);
    my $hh = VIC::list_chip_features($chip);
    if ($hh) {
        my $rtxt = join("\n", @{$hh->{roles}});
        print "\n$chip supports the following features:\n$rtxt\n";
        print "\n$chip has the following memory capabilities:\n";
        my $mh = $hh->{memory};
        foreach (keys %$mh) {
            my $units = 'bytes';
            $units = 'words' if $_ =~ /flash/i; # HACK
            print "$_: " . $mh->{$_} . " $units\n";
        }
    }
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
    my $list_chips = 0;
    my $list_sims = 0;
    my $check_support = undef;
    my $chip_features = undef;
    my $no_hex = 0;

    GetOptions(
        "output=s" => \$output,
        "debug" => \$debug,
        "help" => \$help,
        "pic=s" => \$pic,
        "intermediate" => \$intermediate,
        "version" => \$version,
        "list-chips" => \$list_chips,
        "list-simulators" => \$list_sims,
        "list-features=s" => \$chip_features,
        "supports=s" => \$check_support,
        "no-hex" => \$no_hex,
    ) or usage();
    usage() if $help;
    version() if $version;
    print_chips() if $list_chips;
    print_sims() if $list_sims;
    check_support($check_support) if $check_support;
    list_chip_features($chip_features) if $chip_features;
    return if ($list_chips or $list_sims or $check_support or
                $chip_features);

    $VIC::Debug = $debug;
    $VIC::Intermediate = $intermediate;

    my $fh;
    if (length $output) {
        $output =~ s/\.hex$/\.asm/g;
        open $fh, ">$output" or die "Unable to open $output: $!";
    }
    return usage() unless scalar @ARGV;
    if (defined $pic) {
        $pic =~ s/^PIC/P/gi;
        $pic = lc $pic;
    }
    my ($compiled_out, $chip) = VIC::compile(do {local $/; <>}, $pic);
    if ($fh) {
        print $fh $compiled_out;
    } else {
        print $compiled_out;
    }
    return if $no_hex;
    if (length $output) {
        my ($gpasm, $gplink);
        eval "require Alien::gputils";
        if ($@) {
            $gpasm = which('gpasm');
            $gplink = which('gplink');
        } else {
            my $bindir = Alien::gputils->new()->bin_dir;
            print "Using gpasm and gplink from $bindir\n" if $debug;
            $gpasm = File::Spec->catfile($bindir, 'gpasm');
            $gplink = File::Spec->catfile($bindir, 'gplink');
        }
        my $hexfile = $output;
        my $objfile = $output;
        $hexfile =~ s/\.asm$/\.hex/g;
        $objfile =~ s/\.asm$/\.o/g;
        unless (defined $gpasm and defined $gplink and -e $gpasm and -e $gplink) {
            die "Cannot find gpasm/gplink to compile $output into a hex file $hexfile.";
        }
        print "Using gpasm: $gpasm\n" if $debug;
        print "Using gplink: $gplink\n" if $debug;
        $chip = uc $chip;
        $chip =~ s/^P(\d.*)/PIC$1/g;
        my $gpasm_cmd = "$gpasm -p$chip -M -c $output";
        my $gplink_cmd = "$gplink -q -m -o $hexfile $objfile ";
        system($gpasm_cmd) == 0 or die "Unable to run '$gpasm_cmd': $?";
        system($gplink_cmd) == 0 or die "Unable to run '$gplink_cmd': $?";
    }
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
