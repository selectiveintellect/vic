package VIC::PIC::Gpsim;
use strict;
use warnings;
use bigint;
use Carp;
use Pegex::Base; # use this instead of Mo

our $VERSION = '0.07';
$VERSION = eval $VERSION;

has type => 'gpsim';

has include => 'coff.inc';

has pic => undef; # refer to the PIC object

has led_count => 0;

has scope_channels => 0;

has stimulus_count => 0;

has should_autorun => 0;

has disable => 0;

sub supports_modifier {
    my $self = shift;
    my $mod = shift;
    return 1 if $mod =~ /^(?:every|wave)$/i;
    0;
}

sub init_code {
    my $self = shift;
    my $pic = '';
    $pic = $self->pic->type if $self->pic;
    my $freq = $self->pic->frequency if $self->pic;
    if ($freq) {
        $freq = qq{\t.sim "$pic.frequency = $freq"};
    } else {
        $freq = '';
    }
    return << "...";
;;;; generated common code for the Simulator
\t.sim "module library libgpsim_modules"
\t.sim "$pic.xpos = 200"
\t.sim "$pic.ypos = 200"
$freq
...
}

sub _gen_led {
    my $self = shift;
    my ($id, $x, $y, $name, $port, $color) = @_;
    $color = 'red' unless defined $color;
    $color = 'red' unless $color =~ /red|orange|green|yellow|blue/i;
    $color = lc $color;
    return << "...";
\t.sim "module load led L$id"
\t.sim "L$id.xpos = $x"
\t.sim "L$id.ypos = $y"
\t.sim "L$id.color = $color"
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
    my ($self, $port, $count, $color) = @_;
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
        $code = $self->_gen_led($c, $x, $y, $node, $simport, $color);
    } else {
        $count--;
        if ($self->pic) {
            for (0 .. $count) {
                my $c = $self->led_count + $_;
                my $x = ($_ >= 4) ? 400 : 100;
                my $y = 50 + 50 * $c;
                my $node = lc $port . $c . 'led';
                my $simport = $self->_get_simport($port, $_);
                $code .= $self->_gen_led($c, $x, $y, $node, $simport, $color);
            }
            $self->led_count($self->led_count + $count);
        }
    }
    return $code;
}

sub attach_led7seg {
    my ($self, @pins) = @_;
    my $code = '';
    my @simpins = ();
    my $color = 'red';
    foreach my $p (@pins) {
        if (exists $self->pic->pins->{$p}) {
            push @simpins, $p;
        } elsif (exists $self->pic->ports->{$p}) {
            my $port = $self->pic->ports->{$p};
            foreach (sort(keys %{$self->pic->pins})) {
                next unless defined $self->pic->pins->{$_}->[0];
                push @simpins, $_ if $self->pic->pins->{$_}->[0] eq $port;
            }
        } elsif ($p =~ /red|orange|green|yellow|blue/i) {
            $color = $p;
            next;
        } else {
            carp "Ignoring port $p as it doesn't exist\n";
        }
    }
    return unless scalar @simpins;
    my $id = $self->led_count;
    $self->led_count($id + 1);
    my $x = 500;
    my $y = 50 + 50 * $id;
    $code .= << "...";
\t.sim "module load led_7segments L$id"
\t.sim "L$id.xpos = $x"
\t.sim "L$id.ypos = $y"
...
    my @nodes = qw(cc seg0 seg1 seg2 seg3 seg4 seg5 seg6);
    foreach my $n (@nodes) {
        my $p = shift @simpins;
        my $sp = $self->_get_simport($p);
        $code .= << "...";
\t.sim "node $n"
\t.sim "attach $n $sp L$id.$n"
...
    }
    return $code;
}

sub stop_after {
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
    my $self = shift;
    my $code = '';
    foreach my $port (@_) {
        my $reg = $self->_get_simreg($port);
        next unless $reg;
        $code .= << "...";
\t.sim "log r $reg"
\t.sim "log w $reg"
...
    }
    return $code;
}

sub _set_scope {
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

sub scope {
    my $self = shift;
    my $code = '';
    foreach my $port (@_) {
        $code .= $self->_set_scope($port);
    }
    return $code;
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
    my $assert_msg;
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
        $msg  = "$condition is false" unless $msg;
        $assert_msg = qq{$condition, \\\"$msg\\\"};
    } else {
        if (defined $condition and defined $msg) {
            $assert_msg = qq{$condition, \\\"$msg\\\"};
        } elsif (defined $condition and not defined $msg) {
            $assert_msg = qq{\\\"$condition\\\"};
        } elsif (defined $msg and not defined $condition) {
            $assert_msg = qq{\\\"$msg\\\"};
        } else {
            $assert_msg = qq{\\\"user requested an assert\\\"};
        }
    }

    return << "..."
\t;; break if the condition evaluates to false
\t.assert "$assert_msg"
\tnop ;; needed for the assert
...
}

sub stimulate {
    my $self = shift;
    my $pin = shift;
    my %hh = ();
    foreach my $href (@_) {
        %hh = (%hh, %$href);
    }
    my $period = '';
    $period = $hh{EVERY} if defined $hh{EVERY};
    $period = qq{\t.sim "period $period"} if defined $period;
    my $wave = '';
    my $wave_type = 'digital';
    if (exists $hh{WAVE} and ref $hh{WAVE} eq 'ARRAY') {
        my $arr = $hh{WAVE};
        $wave = "\t.sim \"{ " . join(',', @$arr) . " }\"" if scalar @$arr;
        my $ad = 0;
        foreach (@$arr) {
            $ad |= 1 unless /^\d+$/;
        }
        $wave_type = 'analog' if $ad;
    }
    my $start = $hh{START} || 0;
    $start = qq{\t.sim "start_cycle $start"};
    my $init = $hh{INITIAL} || 0;
    $init = qq{\t.sim "initial_state $init"};
    my $num = $self->stimulus_count;
    $self->stimulus_count($num + 1);
    my $node = "stim$num$pin";
    my $simpin = $self->_get_simport($pin);
    return << "..."
\t.sim \"echo creating stimulus number $num\"
\t.sim \"stimulus asynchronous_stimulus\"
$init
$start
\t.sim \"$wave_type\"
$period
$wave
\t.sim \"name stim$num\"
\t.sim \"end\"
\t.sim \"echo done creating stimulus number $num\"
\t.sim \"node $node\"
\t.sim \"attach $node stim$num $simpin\"
...
}

sub get_autorun_code {
    return qq{\t.sim "run"\n};
}

sub autorun {
    my $self = shift;
    $self->should_autorun(1);
    return "\t;;;; will autorun on start\n";
}

sub stopwatch {
    my ($self, $rollover) = @_;
    my $code = qq{\t.sim "stopwatch.enable = true"\n};
    $code .= qq{\t.sim "stopwatch.rollover = $rollover"\n} if defined $rollover;
    $code .= qq{\t.sim "break stopwatch"\n} if defined $rollover;
    return $code;
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
