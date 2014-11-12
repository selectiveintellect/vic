package VIC::PIC::Functions;
use strict;
use warnings;
use bigint;
use Carp;
use POSIX ();
use VIC::PIC::Roles; # load all the roles
use Moo;
use namespace::clean;

sub doesrole {
    return $_[0]->does('VIC::PIC::Roles::' . $_[1]);
}

sub validate {
    my ($self, $var) = @_;
    return undef unless defined $var;
    return 0 if $var =~ /^\d+$/;
    return 0 unless $self->doesrole('Chip');
    return 1 if exists $self->pins->{$var};
    return 1 if exists $self->registers->{$var};
    return 0;
}

1;
__END__
