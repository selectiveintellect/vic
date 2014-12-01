package VIC::PIC::Functions::ISR;
use strict;
use warnings;
our $VERSION = '0.23';
$VERSION = eval $VERSION;
use Carp;
use POSIX ();
use Moo::Role;

sub isr_var {
    my $self = shift;
    return unless $self->doesroles(qw(Chip ISR));
    my ($cb_start, $cb_end) = @{$self->banks->{common}};
    $cb_start = 0x70 unless $cb_start;
    $cb_start = sprintf "0x%02X", $cb_start;
    return << "...";
cblock $cb_start ;; unbanked RAM that is common across all banks
ISR_STATUS
ISR_W
endc
...
}

sub isr_entry {
    my $self = shift;
    return unless $self->doesroles(qw(Chip ISR));
    unless (exists $self->registers->{STATUS}) {
        carp $self->pic->type, " has no register named STATUS";
        return;
    }
    #TODO: high/low address ?
    my $isr_addr = $self->address->{isr}->[0];
    my $reset_addr = $self->address->{reset}->[0];
    my $count = $isr_addr - $reset_addr - 1;
    my $nops = '';
    for my $i (1 .. $count) {
        $nops .= "\tnop\n";
    }
    return << "...";
$nops
\torg $isr_addr
ISR:
_isr_entry:
\tmovwf ISR_W
\tmovf STATUS, W
\tmovwf ISR_STATUS
...
}

sub isr_exit {
    my $self = shift;
    return unless $self->doesroles(qw(Chip ISR));
    unless (exists $self->registers->{STATUS}) {
        carp $self->pic->type, " has no register named STATUS";
        return;
    }
    return << "...";
_isr_exit:
\tmovf ISR_STATUS, W
\tmovwf STATUS
\tswapf ISR_W, F
\tswapf ISR_W, W
\tretfie
...
}

sub isr_timer {
    my $self = shift;
    return unless $self->doesroles(qw(Chip ISR));
    unless (exists $self->registers->{INTCON}) {
        carp $self->pic->type, " has no register named INTCON";
        return;
    }
    my %isr = @_;
    if (%isr) {
        my $action_label = $isr{ISR};
        my $end_label = $isr{END};
        return unless $action_label;
        return unless $end_label;
        return  << "..."
_isr_timer:
\tbtfss INTCON, T0IF
\tgoto $end_label
\tbcf   INTCON, T0IF
\tgoto $action_label
$end_label:
...
    } else {
        return << "...";
;; enable interrupt servicing
\tbanksel INTCON
\tclrf INTCON
\tbsf INTCON, GIE
\tbsf INTCON, T0IE
;; end of interrupt servicing
...
    }
}

1;
__END__
