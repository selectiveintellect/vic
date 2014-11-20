package VIC;
use strict;
use warnings;

use File::Spec;
use File::Which qw(which);
use Capture::Tiny ':all';
use VIC::Parser;
use VIC::Grammar;
use VIC::Receiver;

our $Debug = 0;
our $Intermediate = 0;
our $GPASM;
our $GPLINK;
our $GPUTILSDIR;

our $VERSION = '0.19';
$VERSION = eval $VERSION;

sub compile {
    my ($input, $pic) = @_;

    my $parser = VIC::Parser->new(
        grammar => VIC::Grammar->new,
        receiver => VIC::Receiver->new(
                    pic_override => $pic,
                    intermediate_inline => $Intermediate,
                ),
        debug => $Debug,
        throw_on_error => 1,
    );

    my $output = $parser->parse($input);
    my $chip = $parser->receiver->current_chip();
    return wantarray ? ($output, $chip) : $output;
}

sub supported_chips { return VIC::Receiver::supported_chips(); }

sub supported_simulators { return VIC::Receiver::supported_simulators(); }

sub is_chip_supported { return VIC::Receiver::is_chip_supported(@_) };

sub list_chip_features { return VIC::Receiver::list_chip_features(@_) };

sub _load_gputils {
    my ($gpasm, $gplink, $bindir);
    my ($stdo, $stde) = capture {
        eval {
            require Alien::gputils;
        };
        unless ($@) {
            my $alien = Alien::gputils->new();
            print "Looking for gpasm and gplink using Alien::gputils\n" if $Debug;
            if ($alien) {
                $gpasm = $alien->gpasm;
                $gplink = $alien->gplink;
                $bindir = $alien->bin_dir;
            }
        }
        unless (defined $gpasm and defined $gplink) {
            print "Looking for gpasm and gplink in \$ENV{PATH}\n" if $Debug;
            $gpasm = which('gpasm');
            $gplink = which('gplink');
        }
        unless (defined $bindir) {
            if ($gpasm) {
                my @dirs = File::Spec->splitpath($gpasm);
                pop @dirs if @dirs;
                $bindir = File::Spec->catdir(@dirs) if @dirs;
            }
        }
    };
    print STDOUT $stdo if ($Debug and $stdo);
    print STDERR $stde if ($Debug and $stde);
    print STDERR "Using gpasm: $gpasm\n" if ($Debug and $gpasm);
    print STDERR "Using gplink: $gplink\n" if ($Debug and $gplink);
    $GPASM = $gpasm;
    $GPLINK = $gplink;
    $GPUTILSDIR = $bindir;
    return wantarray ? ($gpasm, $gplink, $bindir) : [$gpasm, $gplink, $bindir];
}

sub gputils {
    return ($GPASM, $GPLINK, $GPUTILSDIR) if (defined $GPASM and defined $GPLINK
                                                and defined $GPUTILSDIR);
    return &_load_gputils();
}

sub gpasm {
    return $GPASM if defined $GPASM;
    my @out = &_load_gputils();
    return $out[0];
}

sub gplink {
    return $GPLINK if defined $GPLINK;
    my @out = &_load_gputils();
    return $out[1];
}

sub bindir {
    return $GPUTILSDIR if defined $GPUTILSDIR;
    my @out = &_load_gputils();
    return $out[2];
}

sub assemble($$) {
    my ($chip, $output) = @_;
    return unless defined $chip;
    return unless defined $output;
    my $hexfile = $output;
    my $objfile = $output;
    if ($output =~ /\.asm$/) {
        $hexfile =~ s/\.asm$/\.hex/g;
        $objfile =~ s/\.asm$/\.o/g;
    } else {
        $hexfile = $output . '.hex';
        $objfile = $output . '.o';
    }
    my ($gpasm, $gplink, $bindir) = VIC::gputils();
    unless (defined $gpasm and defined $gplink and -e $gpasm and -e $gplink) {
        die "Cannot find gpasm/gplink to compile $output into a hex file $hexfile.";
    }
    my ($inc1, $inc2) = ('', '');
    if (defined $bindir) {
        my @dirs = File::Spec->splitdir($bindir);
        my $l = pop @dirs if @dirs;
        if (defined $l and $l ne 'bin') {
            push @dirs, $l; # return the last directory
        }
        my @includes = ();
        my @linkers = ();
        push @includes, File::Spec->catdir(@dirs, 'header');
        push @linkers, File::Spec->catdir(@dirs, 'lkr');
        push @includes, File::Spec->catdir(@dirs, 'share', 'gputils', 'header');
        push @linkers, File::Spec->catdir(@dirs, 'share', 'gputils', 'lkr');
        foreach (@includes) {
            $inc1 .= " -I $_ " if -d $_;
        }
        foreach (@linkers) {
            $inc2 .= " -I $_ " if -d $_;
        }
    }
    my $gpasm_cmd = "$gpasm $inc1 -p $chip -M -c $output";
    my $gplink_cmd = "$gplink $inc2 -q -m -o $hexfile $objfile ";
    system($gpasm_cmd) == 0 or die "Unable to run '$gpasm_cmd': $?";
    system($gplink_cmd) == 0 or die "Unable to run '$gplink_cmd': $?";
    1;
}

1;

=encoding utf8

=head1 NAME

VIC - A Viciously Simple Syntax for PIC Microcontrollers

=head1 SYNOPSIS

    $ vic program.vic -o program.asm

    $ vic -h

=head1 DESCRIPTION

Refer documentation at L<http://selectiveintellect.github.io/vic/>.

=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
