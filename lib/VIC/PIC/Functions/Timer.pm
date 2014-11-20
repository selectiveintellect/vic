package VIC::PIC::Functions::Timer;
use strict;
use warnings;
our $VERSION = '0.20';
$VERSION = eval $VERSION;
use Carp;
use POSIX ();
use Moo::Role;

sub _get_timer_prescaler {
    my ($self, $freq) = @_;
    my $f_osc = $self->f_osc;
    my $scale = POSIX::ceil(($f_osc / 4) / $freq); # assume prescaler = 1 here
    if ($scale <=2) {
        $scale = 2;
    } elsif ($scale > 2 && $scale <= 4) {
        $scale = 4;
    } elsif ($scale > 4 && $scale <= 8) {
        $scale = 8;
    } elsif ($scale > 8 && $scale <= 16) {
        $scale = 16;
    } elsif ($scale > 16 && $scale <= 32) {
        $scale = 32;
    } elsif ($scale > 32 && $scale <= 64) {
        $scale = 64;
    } elsif ($scale > 64 && $scale <= 128) {
        $scale = 128;
    } elsif ($scale > 128 && $scale <= 256) {
        $scale = 256;
    } else {
        $scale = 256;
    }
    my $psx = $self->timer_prescaler->{$scale} || $self->timer_prescaler->{256};
    return $psx;
}

sub timer_enable {
    my ($self, $tmr, $freq, %isr) = @_;
    return unless $self->doesroles(qw(Timer Chip));
    unless (exists $self->timer_pins->{$tmr}) {
        carp "$tmr is not a timer.";
        return;
    }
    unless (exists $self->registers->{OPTION_REG}) {
        carp $self->pic->type, " does not have the register OPTION_REG";
        return;
    }
    my $psx = $self->_get_timer_prescaler($freq);
    my $code = << "...";
;; timer prescaling
\tbanksel OPTION_REG
\tclrw
\tiorlw B'00000$psx'
\tmovwf OPTION_REG
...
    my $end_code = << "...";
;; clear the timer
\tbanksel $tmr
\tclrf $tmr
...
    if (%isr) {
        $code .= $self->isr_timer();
    }
    $code .= "\n$end_code\n";
    my $funcs = {};
    my $macros = {};
    if (%isr) {
        $funcs->{isr_timer} = $self->isr_timer(%isr);
    }
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub timer_disable {
    my ($self, $tmr) = @_;
    return unless $self->doesroles(qw(Timer Chip));
    unless (exists $self->timer_pins->{$tmr}) {
        carp "$tmr is not a timer.";
        return;
    }
    unless (exists $self->registers->{OPTION_REG} and
        exists $self->registers->{INTCON}) {
        carp $self->pic->type, " does not have the register OPTION_REG/INTCON";
        return;
    }
    return << "...";
\tbanksel INTCON
\tbcf INTCON, T0IE ;; disable only the timer bit
\tbanksel OPTION_REG
\tmovlw B'00001000'
\tmovwf OPTION_REG
\tbanksel $tmr
\tclrf $tmr
...

}

sub timer {
    my ($self, %action) = @_;
    return unless exists $action{ACTION};
    return unless $self->doesroles(qw(Timer Chip));
    return unless exists $action{END};
    unless (exists $self->registers->{INTCON}) {
        carp $self->pic->type, " does not have the register INTCON";
        return;
    }
    return << "...";
\tbtfss INTCON, T0IF
\tgoto $action{END}
\tbcf INTCON, T0IF
\tgoto $action{ACTION}
$action{END}:
...
}

1;
__END__
