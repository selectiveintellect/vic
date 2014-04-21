package VIC::PIC::Gpsim;
use strict;
use warnings;
use bigint;
use Carp;
use Pegex::Base; # use this instead of Mo

our $VERSION = '0.06';
$VERSION = eval $VERSION;

has type => 'gpsim';

has include => 'coff.inc';

has pic => undef;

sub attach_led {
    my ($self, $port, $count) = @_;
    $count = 1 unless $count;
    $count = 1 if int($count) < 1;
    1;
}

sub limit {
    my ($self, $secs) = @_;
    # convert $secs to cycles
    1;
}

1;

=encoding utf8

=head1 NAME

VIC::Receiver

=head1 SYNOPSIS

The Pegex::Receiver class for handling the grammar.

=head1 DESCRIPTION

INTERNAL CLASS.

=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
