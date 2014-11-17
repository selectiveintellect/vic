package VIC;
use strict;
use warnings;

use VIC::Parser;
use VIC::Grammar;
use VIC::Receiver;

our $Debug = 0;
our $Intermediate = 0;

our $VERSION = '0.14';
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

    $parser->parse($input);
}

sub supported_chips { return VIC::Receiver::supported_chips(); }

sub supported_simulators { return VIC::Receiver::supported_simulators(); }

sub is_chip_supported { return VIC::Receiver::is_chip_supported(@_) };

sub list_chip_features { return VIC::Receiver::list_chip_features(@_) };

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
