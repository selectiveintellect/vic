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

has pic => undef; # refer to the PIC object

has led_count => 0;

has scope_channels => 0;

sub init_code {
    my $self = shift;
    my $pic = '';
    $pic = $self->pic->type if $self->pic;
    return << "...";
;;;; generated common code for the Simulator
\t.sim "module library libgpsim_modules"
\t.sim "$pic.xpos = 200";
\t.sim "$pic.ypos = 200";
...
}

sub _gen_led {
    my $self = shift;
    my ($id, $x, $y, $name, $port) = @_;
    return << "...";
\t.sim "module load led L$id"
\t.sim "L$id.xpos = $x"
\t.sim "L$id.ypos = $y"
\t.sim "node $name"
\t.sim "attach $name $port L$id.in"
...
}

sub _get_simreg {
    my ($self, $port) = @_;
    my $simreg = lc $port;
    if ($self->pic) {
        if (exists $self->pic->ports->{$port}) {
            # this is a port
            $simreg = lc $port;
        } elsif (exists $self->pic->pins->{$port}) {
            # this is a pin
            my ($p1, $p2, $p3) = @{$self->pic->pins->{$port}};
            $simreg = lc "PORT$p1";
        } else {
            my $pic = $self->pic->type;
            carp "Cannot find '$port' in PIC $pic. Using '$simreg'";
        }
    }
    return $simreg;
}

sub _get_simport {
    my ($self, $port, $pin) = @_;
    my $simport = lc $port;
    if ($self->pic) {
        if (exists $self->pic->ports->{$port}) {
            # this is a port
            my $p1 = $self->pic->ports->{$port};
            $simport = lc "PORT$p1";
            $simport .= $pin if defined $pin;
        } elsif (exists $self->pic->pins->{$port}) {
            # this is a pin
            my ($p1, $p2, $p3) = @{$self->pic->pins->{$port}};
            $simport = lc "PORT$p1$p2";
        } else {
            my $pic = $self->pic->type;
            carp "Cannot find '$port' in PIC $pic. Using '$simport'";
        }
    }
    return $simport;
}

sub _get_portpin {
    my ($self, $port) = @_;
    my $simport = lc $port;
    my $simpin;
    if ($self->pic) {
        if (exists $self->pic->ports->{$port}) {
            # this is a port
            my $p1 = $self->pic->ports->{$port};
            $simport = lc "PORT$p1";
        } elsif (exists $self->pic->pins->{$port}) {
            # this is a pin
            my ($p1, $p2, $p3) = @{$self->pic->pins->{$port}};
            $simport = lc "PORT$p1";
            $simpin = $p2;
        } else {
            return;
        }
    }
    return wantarray ? ($simport, $simpin) : $simport;
}

sub attach_led {
    my ($self, $port, $count) = @_;
    $count = 1 unless $count;
    $count = 1 if int($count) < 1;
    my $code = '';
    if ($count == 1) {
        my $c = $self->led_count;
        my $node = lc $port . 'led';
        $self->led_count($c + 1);
        my $x = ($c >= 4) ? 400 : 100;
        my $y = 50 + 50 * $c;
        # use the default pin 0 here
        my $simport = $self->_get_simport($port, 0);
        $code = $self->_gen_led($c, $x, $y, $node, $simport);
    } else {
        $count--;
        if ($self->pic) {
            for (0 .. $count) {
                my $c = $self->led_count + $_;
                my $x = ($_ >= 4) ? 400 : 100;
                my $y = 50 + 50 * $c;
                my $node = lc $port . $c . 'led';
                my $simport = $self->_get_simport($port, $_);
                $code .= $self->_gen_led($c, $x, $y, $node, $simport);
            }
            $self->led_count($self->led_count + $count);
        }
    }
    return $code;
}

sub limit {
    my ($self, $usecs) = @_;
    # convert $secs to cycles
    my $cycles = $usecs * 10;
    my $code = << "...";
\t.sim "break c $cycles"
...
    return $code;
}

sub logfile {
    my ($self, $file) = @_;
    $file = '' unless defined $file;
    return "\t.sim \"log lxt $file\"\n" if $file =~ /\.lxt/i;
    return "\t.sim \"log on $file\"\n";
}

sub log {
    my ($self, $port) = @_;
    my $reg = $self->_get_simreg($port);
    return unless $reg;
    my $log_init = '';
    return << "...";
\t.sim "log r $reg"
\t.sim "log w $reg"
...
}

sub scope {
    my ($self, $port) = @_;
    my $simport = $self->_get_simport($port);
    my $chnl = $self->scope_channels;
    carp "Maximum of 8 channels can be used in the scope\n" if $chnl > 7;
    return '' if $chnl > 7;
    if (lc($simport) eq lc($port)) {
        my @code = ();
        for (0 .. 7) {
            $simport = $self->_get_simport($port, $_);
            if ($self->scope_channels < 8) {
                $chnl = $self->scope_channels;
                push @code, "\t.sim \"scope.ch$chnl = \\\"$simport\\\"\"";
                $self->scope_channels($chnl + 1);
            }
            carp "Maximum of 8 channels can be used in the scope\n" if $chnl > 7;
            last if $chnl > 7;
        }
        return join("\n", @code);
    } else {
        $self->scope_channels($chnl + 1);
        return << "...";
\t.sim "scope.ch$chnl = \\"$simport\\""
...
    }
}

### have to change the operator back to the form acceptable by gpsim
sub _get_operator {
    my $self = shift;
    my $op = shift;
    return '==' if $op eq 'EQ';
    return '!=' if $op eq 'NE';
    return undef;
}

sub sim_assert {
    my ($self, $condition, $msg) = @_;
    if ($condition =~ /@@/) {
        my @args = split /@@/, $condition;
        my $literal = qr/^\d+$/;
        if (scalar @args == 3) {
            my $lhs = shift @args;
            my $op = shift @args;
            my $rhs = shift @args;
            my $op2 = $self->_get_operator($op);
            if ($lhs !~ $literal) {
                my ($port, $pin) = $self->_get_portpin($lhs);
                if (defined $pin) {
                    my $pval = sprintf "0x%02X", (1 << $pin);
                    $lhs = lc "($port & $pval)";
                } elsif (defined $port) {
                    $lhs = lc $port;
                } else {
                    # may be a variable
                    $lhs = uc $lhs;
                }
            } else {
                $lhs = sprintf "0x%02X", $lhs;
            }
            if ($rhs !~ $literal) {
                my ($port, $pin) = $self->_get_portpin($lhs);
                if (defined $pin) {
                    my $pval = sprintf "0x%02X", (1 << $pin);
                    $rhs = lc "($port & $pval)";
                } elsif (defined $port) {
                    $rhs = lc $port;
                } else {
                    # may be a variable
                    $rhs = uc $rhs;
                }
            } else {
                $rhs = sprintf "0x%02X", $rhs;
            }
            $condition = "$lhs $op2 $rhs";
        }
        #TODO: handle more complex expressions
    }
    $msg  = "$condition is false" unless $msg;
    return << "..."
\t;; break if the condition evaluates to false
\t.assert "$condition, \\\"$msg\\\""
\tnop ;; needed for the assert
...
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
