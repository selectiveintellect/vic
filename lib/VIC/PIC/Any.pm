package VIC::PIC::Any;
use strict;
use warnings;
use Carp;

our $VERSION = '0.13';
$VERSION = eval $VERSION;

use VIC::PIC::Gpsim;

# use this to map various PICs to their classes
# allows for the same class to be used for different pics
use constant PICS => {
    # PIC12
    P12F683 => 'P12F683',
    # PIC16
    P16F690 => 'P16F690',
    P16F631 => 'P16F631',
    P16F677 => 'P16F677',
    P16F685 => 'P16F685',
    P16F687 => 'P16F687',
    P16F689 => 'P16F689',
    P16F627A => 'P16F627A',
    P16F628A => 'P16F628A',
    P16F648A => 'P16F648A',
};

use constant PICREGEX => {
    # PIC18
    qr/P18F\d\d2/i => 'P18FXX2',
    qr/P18F1\dK50/i => 'P18F1XK50',
    qr/P18LF1\dK50/i => 'P18LF1XK50',
};

use constant SIMS => {
    gpsim => 'Gpsim',
};

sub _get_pic_type {
    my $type = shift;
    my $ctype = PICS->{uc $type};
    unless (defined $ctype) {
        foreach my $regex (keys %{+PICREGEX}) {
            if ($type =~ $regex) {
                $ctype = PICREGEX->{$regex};
                last;
            }
        }
    }
    return $ctype;
}

sub new {
    my ($class, $type) = @_;
    if (uc $type eq 'ANY') {
        die "You need to specify the type of the chip on the commandline to use 'Any'\n";
        return;
    }
    my $ctype = &_get_pic_type($type);
    return unless defined $ctype;
    $class =~ s/::Any/::$ctype/g;
    eval "require $class;" or croak "Unable to load $class: $@";
    return $class->new(type => lc $ctype);
}

sub new_simulator {
    my ($class, %hh) = @_;
    my $stype = 'Gpsim';
    if (exists $hh{type}) {
        $stype = SIMS->{lc $hh{type}};
        carp "No simulator of type $hh{type}\n" unless $stype;
        return;
    }
    $class =~ s/::Any/::$stype/g;
    $hh{type} = lc $stype;
    return $class->new(%hh);
}

sub supported_chips {
    my @chips = sort(keys %{+PICS});
    push @chips, sort(values %{+PICREGEX});
    return wantarray ? @chips : \@chips;
}

sub supported_simulators {
    my @sims = sort(keys %{+SIMS});
    return wantarray ? @sims : \@sims;
}

sub is_chip_supported {
    my $chip = shift;
    my $ret = &_get_pic_type(uc $chip);
    return (defined $ret) ? 1 : 0;
}

1;

=encoding utf8

=head1 NAME

VIC::PIC::Any

=head1 SYNOPSIS

A wrapper class that returns the appropriate object for the given PIC
microcontroller name. This is used internally by VIC.

=head1 DESCRIPTION

=over

=item B<new PICNAME>

Returns an object for the given microcontroller name such as 'P16F690'.

=back

=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
