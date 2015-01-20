package VIC::PIC::Functions::USART;
use strict;
use warnings;
our $VERSION = '0.23';
$VERSION = eval $VERSION;
use Carp;
use POSIX ();
use Scalar::Util qw(looks_like_number);
use Moo::Role;

sub usart_setup {
    my ($self, $io, $ad, $outp) = @_;
    return unless $self->doesroles(qw(USART GPIO CodeGen Chip));
    return unless $outp =~ /UART|USART/;
    ## we do not check for defined values since this is called internally and
    #not directly by the user
    if ($ad =~ /analog/i) {
        carp "$outp cannot have analog I/O";
        return;
    }
    $io = 0 if $io =~ /output/i; #transmit
    $io = 1 if $io =~ /input/i; #receive
    return unless ($io == 0 or $io == 1);
    my $sync = ($outp =~ /^UART/) ? 0 : 1; # the other is USART
    my $ipin = $self->usart_pins->{async_in};
    my $opin = $self->usart_pins->{async_out};
    my $sclk = $self->usart_pins->{sync_clock};
    my $sdat = $self->usart_pins->{sync_data};
    return unless (defined $ipin and defined $opin);
    #return if ($sync == 1 and not defined $sclk and not defined $sdat);
    return unless (exists $self->pins->{$ipin} and exists $self->pins->{$opin});
    if (exists $self->registers->{SPBRGH} and
        exists $self->registers->{SPBRG} and
        exists $self->registers->{BAUDCTL}) {
        ## Enhanced USART (16-bit)
        ## Required registers TXSTA, RCSTA, BAUDCTL, TXREG, RCREG
        ## To enable the transmitter for asynchronous ops
        ## TXEN = 1, SYNC = 0, SPEN = 1
        ## if TX/CK pin is shared with analog I/O then clear the appropriate
        ## ANSEL bit
        ## find if the $ipin/$opin is shared with an analog pin
        my ($baud_code, $io_code, $an_code) = ('', '', '');
        my $key = $sync ? 'usart' : 'uart';
        ## calculate the Baud rate
        my $baudrate = $self->code_config->{$key}->{baud};
        # find closest approximation of baud-rate
        # if baud-rate not given assume 9600
        my $f_osc = $self->code_config->{$key}->{f_osc} || $self->f_osc;
        my $baudref = $self->usart_baudrates($baudrate, $f_osc, $sync);
        unless (ref $baudref eq 'HASH') {
            carp "Baud rate $baudrate cannot be supported";
            return;
        }
        my $spbrgh = sprintf "0x%02X", (($baudref->{SPBRG} >> 8) & 0xFF);
        my $spbrg = sprintf "0x%02X", ($baudref->{SPBRG} & 0xFF);
        my $baudctl_code = '';
        if ($baudref->{BRG16}) {
            $baudctl_code .= "\tbanksel BAUDCTL\n\tbsf BAUDCTL, BRG16\n";
        } else {
            $baudctl_code .= "\tbanksel BAUDCTL\n\tbcf BAUDCTL, BRG16\n";
        }
        if ($baudref->{BRGH}) {
            $baudctl_code .= "\tbanksel TXSTA\n\tbsf TXSTA, BRGH\n";
        } else {
            $baudctl_code .= "\tbanksel TXSTA\n\tbcf TXSTA, BRGH\n";
        }
        chomp $baudctl_code;
        my $cbaud = sprintf "%0.04f", $baudref->{actual};
        my $ebaud = sprintf "%0.06f%%", $baudref->{error};
        $baud_code .= <<"...";
;;;Desired Baud: $baudref->{baud}
;;;Calculated Baud: $cbaud
;;;Error: $ebaud
;;;SPBRG: $baudref->{SPBRG}
;;;BRG16: $baudref->{BRG16}
;;;BRGH: $baudref->{BRGH}
$baudctl_code
\tbanksel SPBRG
\tmovlw $spbrgh
\tmovwf SPBRGH
\tmovlw $spbrg
\tmovwf SPBRG
...
        if (exists $self->registers->{ANSEL}) {
            my $iopin = ($io == 1) ? $ipin : $opin;
            my $pin_no = $self->pins->{$iopin};
            my $allpins = $self->pins->{$pin_no};
            unless (ref $allpins eq 'ARRAY') {
                carp "Invalid data for pin $pin_no";
                return;
            }
            foreach my $anpin (@$allpins) {
                next unless exists $self->analog_pins->{$anpin};
                my ($pno, $pbit) = @{$self->analog_pins->{$anpin}};
                my $ansel = 'ANSEL';
                if (exists $self->registers->{ANSELH}) {
                    $ansel = ($pbit >= 8) ? 'ANSELH' : 'ANSEL';
                }
                $an_code = "\tbanksel $ansel\n\tbcf $ansel, ANS$pbit";
                last;
            }
        }
        unless (exists $self->registers->{TXSTA} and
            exists $self->registers->{RCSTA}) {
            carp "Register TXSTA & RCSTA are required for operations for $outp";
            return;
        }
        if ($io) {
            # receive
            if ($sync) {
                #TODO
                carp "Synchronous operations not implemented\n";
                return;
            }
            $io_code .= <<"...";
\tbanksel TXSTA
\tbcf TXSTA, SYNC ;; asynchronous operation
\tbanksel RCSTA
\tbsf RCSTA, SPEN ;; serial port enable
\tbsf RCSTA, CREN ;; continuous receive enable
$an_code
...
        } else {
            # transmit
            if ($sync) {
                #TODO
                carp "Synchronous operations not implemented\n";
                return;
            }
            $io_code .= <<"...";
\tbanksel TXSTA
\tbcf TXSTA, SYNC ;; asynchronous operation
\tbsf TXSTA, TXEN ;; transmit enable
\tbanksel RCSTA
\tbsf RCSTA, SPEN ;; serial port enable
$an_code
...
        }
        return <<"EUSARTCODE";
$baud_code
$io_code
EUSARTCODE
    } elsif (exists $self->registers->{SPBRG}) {
        ## USART (8-bit)
    } else {
        carp "$outp for chip ", $self->pic->type, " is not supported";
        return;
    }
}

sub usart_write {
    my ($self, $outp, $data) = @_;
    return unless $self->doesroles(qw(USART GPIO CodeGen Chip));
    return unless $outp =~ /UART|USART/;
    return unless defined $data;
    # check if $data is a string or value or variable
    if (looks_like_number($data) and $data !~ /^@/) {
        return ";;; sending the number '$data' to $outp";
    }
    $data = substr($data, 1) if $data =~ /^@/;
    return ";;; sending the string '$data' to $outp";
}

1;
__END__
