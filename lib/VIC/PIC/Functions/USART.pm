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
    my ($self, $outp, $baudr) = @_;
    return unless $self->doesroles(qw(USART GPIO CodeGen Chip));
    return unless $outp =~ /UART|USART/;
    my $io = 'output';#FIXME
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
        my $baudrate = $baudr;
        $baudrate = $self->code_config->{$key}->{baud} unless defined $baudr;
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
            my $ipin_no = $self->pins->{$ipin};
            my $opin_no = $self->pins->{$opin};
            my $iallpins = $self->pins->{$ipin_no};
            my $oallpins = $self->pins->{$opin_no};
            unless (ref $iallpins eq 'ARRAY') {
                carp "Invalid data for pin $ipin_no";
                return;
            }
            unless (ref $oallpins eq 'ARRAY') {
                carp "Invalid data for pin $opin_no";
                return;
            }
            my @anpins = ();
            foreach (@$iallpins) {
                push @anpins, $_ if exists $self->analog_pins->{$_};
            }
            foreach (@$oallpins) {
                push @anpins, $_ if exists $self->analog_pins->{$_};
            }
            my $pansel = '';
            foreach (sort @anpins) {
                my ($pno, $pbit) = @{$self->analog_pins->{$_}};
                my $ansel = 'ANSEL';
                if (exists $self->registers->{ANSELH}) {
                    $ansel = ($pbit >= 8) ? 'ANSELH' : 'ANSEL';
                }
                if ($ansel ne $pansel) {
                    $an_code .= "\tbanksel $ansel\n";
                    $pansel = $ansel;
                }
                $an_code .= "\tbcf $ansel, ANS$pbit\n";
            }
        }
        unless (exists $self->registers->{TXSTA} and
            exists $self->registers->{RCSTA}) {
            carp "Register TXSTA & RCSTA are required for operations for $outp";
            return;
        }
        if ($sync) {
            #TODO
            carp "Synchronous operations not implemented\n";
            return;
        }
        $io_code .= <<"...";
\tbanksel TXSTA
\t;; asynchronous operation
\tbcf TXSTA, SYNC
\t;; transmit enable
\tbsf TXSTA, TXEN
\tbanksel RCSTA
\t;; serial port enable
\tbsf RCSTA, SPEN
\t;; continuous receive enable
\tbsf RCSTA, CREN
$an_code
...
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

sub _usart_write_byte_var {
    return <<'...';
;;;;;;; USART WRITE VARS ;;;;;;
VIC_VAR_USART_UDATA udata
VIC_VAR_USART_LEN res 1
VIC_VAR_USART_WIDX res 1
...
}

sub _usart_write_byte {
    return <<'....';
m_usart_write_byte macro tblentry
    local _usart_write_byte_loop_0
    clrf VIC_VAR_USART_WIDX
_usart_write_byte_loop_0:
    movf VIC_VAR_USART_WIDX, W
    call tblentry
    movwf TXREG
    btfss TXSTA, TRMT
    goto $ - 1
    incf VIC_VAR_USART_WIDX, F
    movf VIC_VAR_USART_WIDX, W
    bcf STATUS, Z
    xorlw VIC_VAR_USART_LEN
    btfss STATUS, Z
    goto _usart_write_byte_loop_0
    endm
....
}

sub usart_write {
    my ($self, $outp, $data) = @_;
    return unless $self->doesroles(qw(USART GPIO CodeGen Chip));
    return unless $outp =~ /US?ART/;
    return unless defined $data;
    my ($code, $funcs, $macros, $tables) = ('', {}, {}, []);
    # check if $data is a string or value or variable
    my @bytearr = ();
    my $nstr;
    my $table_entry = '';
    if (ref $data eq 'HASH') {
        # this ia a string
        $nstr = $data->{string};
        $nstr = substr($nstr, 1) if $nstr =~ /^@/;
        $code .= ";;; sending the string '$nstr' to $outp\n";
        @bytearr = split //, $nstr;
        push @$tables, {
            bytes => [map { sprintf "0x%02X", ord($_) } @bytearr],
            name => $data->{name},
            comment => "\t;;storing string '$nstr'",
        };
        $table_entry = $data->{name};
    } else {
        if (looks_like_number($data) and $data !~ /^@/) {
            $code .= ";;; sending the number '$data' to $outp in big-endian mode\n";
            my $nstr = pack "N", $data;
            $nstr =~ s/^\x00{1,3}//g; # remove the beginning nulls
            @bytearr = split //, $nstr;
            $table_entry = sprintf("_vic_bytes_0x%02X", $data);
            push @$tables, {
                bytes => [map { sprintf "0x%02X", ord($_) } @bytearr],
                name => $table_entry,
                comment => "\t;;storing number $data",
            };
        } else {
            $code .= ";;; sending the variable '$data' to $outp\n";
            carp 'USART write not implemented for variables!';
            return;
        }
    }
    ## length has to be 1 byte only
    ## use TXREG and TRMT bit of TXSTA to check if it is done
    ## by polling the TRMT check
    ## use DECFSZ to manage the loop
    ## use a table to store multiple strings/byte arrays
    ## TODO: call store_string() to store the string/array of bytes
    ## the best way is to store all strings as temporary variables and
    ## send the variable into the functions to be detected appropriately
    ## use the dt directive to store each string entry in a table
    ## the byte arrays generated by a number can be pushed back using a
    ## temporary variable
    if (scalar @bytearr > 256) {
        carp "Warning: Cannot write more than 256 bytes at a time to $outp. You tried to write ", scalar @bytearr;
    }
    my $len = scalar(@bytearr) < 256 ? scalar(@bytearr) : 0xFF;
    $len = sprintf "0x%02X", $len;
    $macros->{m_usart_write_byte} = $self->_usart_write_byte;
    $macros->{m_usart_write_var} = $self->_usart_write_byte_var;
    $code .= <<"...";
;;;; byte array has length $len
    movlw $len
    movwf VIC_VAR_USART_LEN
    m_usart_write_byte $table_entry
...
    return wantarray ? ($code, $funcs, $macros, $tables) : $code;
}

1;
__END__
