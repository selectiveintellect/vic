package VIC::PIC::Any;
use strict;
use warnings;

use VIC::PIC::P16F690;

# use this to map various PICs to their classes
# allows for the same class to be used for different pics
use constant PICS => {
    P16F690 => 'P16F690',
};

sub new {
    my ($class, $type) = @_;
    my $utype = PICS->{uc $type};
    $class =~ s/::Any/::$utype/g;
    return $class->new(type => lc $utype);
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
