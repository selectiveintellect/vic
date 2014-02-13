package VIC;
use strict;
use warnings;

use Pegex::Parser;
use VIC::Grammar;
use VIC::PIC;

our $Debug = 0;
our $VERSION = '0.01';
$VERSION = eval $VERSION;

sub compile {
    my ($input, $pic) = @_;

    my $parser = Pegex::Parser->new(
        grammar => VIC::Grammar->new,
        receiver => VIC::PIC->new(pic_override => $pic),
        debug => $Debug,
    );

    $parser->parse($input);
}

1;

=encoding utf8

=head1 NAME

VIC - A Viciously Simple Syntax for PIC

=head1 SYNOPSIS

    $ vic program.vic -o program.asm

=head1 DESCRIPTION

TODO

=head1 AUTHOR

Vikas N Kumar <vikas@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2014. Vikas N Kumar

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
