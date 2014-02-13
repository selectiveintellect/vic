package VIC::PIC::P16F690;
use strict;
use warnings;
use POSIX ();
use Pegex::Base; # use this instead of Mo

has type => 'p16f690';

has include => 'p16f690.inc';

has org => 0;

has address_bits => 8;

has address_range => [ 0x0000, 0x0FFF ]; # 4K

has reset_address => 0x0000;

has isr_address => 0x0004;

has program_counter_size => 13; # PCL and PCLATH<4:0>

has stack_size => 8; # 8-level x 13-bit wide

has banks => {
    # general purpose registers
    gpr => {
        [ 0x20, 0x7F ],
        [ 0xA0, 0xEF ],
        [ 0x120, 0x16F ],
        [ ], # no GPRs in bank 4
    },
    # special function registers
    sfr => {
        [ 0x00, 0x1F ],
        [ 0x80, 0x9F ],
        [ 0x100, 0x11F ],
        [ 0x180, 0x19F ],
    },
    bank_size => 0x80,
};

has register_banks => {
    # 0x01
    TMR0 => [ 0, 2 ],
    OPTION_REG => [ 1, 3 ],
    # 0x02
    PCL => [ 0 .. 3 ],
    # 0x03
    STATUS => [ 0 .. 3 ],
    # 0x04
    FSR => [ 0 .. 3 ],
    # 0x05
    PORTA => [ 0, 2 ],
    TRISA => [ 1, 3 ],
    # 0x06
    PORTB => [ 0, 2 ],
    TRISB => [ 1, 3 ],
    # 0x07
    PORTC => [ 0, 2 ],
    TRISC => [ 1, 3 ],
    # 0x0A
    PCLATH => [ 0 .. 3 ],
    # 0x0B
    INTCON => [ 0 .. 3 ],
    # 0x0C
    PIR1 => [ 0 ],
    PIE1 => [ 1 ],
    EEDAT => [ 2 ],
    EECON1 => [ 3 ],
    # 0x0D
    PIR2 => [ 0 ],
    PIE2 => [ 1 ],
    EEADR => [ 2 ],
    EECON2 => [ 3 ],
    # 0x0E
    TMR1L => [ 0 ],
    PCON => [ 1 ],
    EEDATH => [ 2 ],
    # 0x0F
    TMR1H => [ 0 ],
    OSCCON => [ 1 ],
    EEADRH => [ 2 ],
    # 0x10
    T1CON => [ 0 ],
    OSCTUNE => [ 1 ],
    # 0x11
    TMR2 => [ 0 ],
    # 0x12
    T2CON => [ 0 ],
    PR2 => [ 1 ],
    # 0x13
    SSPBUF => [ 0 ],
    SSPADD => [ 1 ],
    # 0x14
    SSPCON => [ 0 ],
    SSPSTAT => [ 1 ],
    # 0x15
    CCPR1L => [ 0 ],
    WPUA => [ 1 ],
    WPUB => [ 2 ],
    # 0x16
    CCPR1H => [ 0 ],
    IOCA => [ 1 ],
    IOCB => [ 2 ],
    # 0x17
    CCP1CON => [ 0 ],
    WDTCON => [ 1 ],
    # 0x18
    RCSTA => [ 0 ],
    TXSTA => [ 1 ],
    VRCON => [ 2 ],
    # 0x19
    TXREG => [ 0 ],
    SPBRG => [ 1 ],
    CM1CON0 => [ 2 ],
    # 0x1A
    RCREG => [ 0 ],
    SPBRGH => [ 1 ],
    CM2CON0 => [ 2 ],
    # 0x1B
    BAUDCTL => [ 1 ],
    CM2CON1 => [ 2 ],
    # 0x1C
    PWM1CON => [ 0 ],
    # 0x1D
    ECCPAS => [ 0 ],
    PSTRCON => [ 3 ],
    # 0x1E
    ADRESH => [ 0 ],
    ADRESL => [ 1 ],
    ANSEL => [ 2 ],
    PSTRCON => [ 3 ],
    # 0x1F
    ADCON0 => [ 0 ],
    ADCON1 => [ 1 ],
    ANSELH => [ 2 ],
};

has pin_count => 20;

has pins => {
    1 => 'Vdd',
    2 => 'RA5',
    3 => 'RA4',
    4 => 'RA3',
    5 => 'RC5',
    6 => 'RC4',
    7 => 'RC3',
    8 => 'RC6',
    9 => 'RC7',
    10 => 'RB7',
    11 => 'RB6',
    12 => 'RB5',
    13 => 'RB4',
    14 => 'RC2',
    15 => 'RC1',
    16 => 'RC0',
    17 => 'RA2',
    18 => 'RA1',
    19 => 'RA0',
    20 => 'Vss',
};

has gpio_pins => {
    RA0 => 19,
    RA1 => 18,
    RA2 => 17,
    RA4 => 3,
    RA5 => 2,
    RC0 => 16,
    RC1 => 15,
    RC2 => 14,
    RC3 => 7,
    RC4 => 6,
    RC5 => 5,
    RC6 => 8,
    RC7 => 9,
    RB4 => 13,
    RB5 => 12,
    RB6 => 11,
    RB7 => 10,
};

has input_pins => {
    RA3 => 4,
};

has power_pins => {
    Vdd => 1,
    Vss => 20,
    Vpp => 4,
    ULPWU => 19,
    MCLR => 4,
};

has analog_pins => {
    # use ANSEL for pins AN0-AN7 and ANSELH for AN8-AN11
    AN0 => 19,
    AN1 => 18,
    AN2 => 17,
    AN3 => 3,
    AN4 => 16,
    AN5 => 15,
    AN6 => 14,
    AN7 => 7,
    AN8 => 8,
    AN9 => 9,
    AN10 => 13,
    AN11 => 12,
};

has comparator_pins => {
    C1IN => 19,
    C12IN0 => 18,
    C1OUT => 17,
    C2IN => 16,
    C12IN1 => 15,
    C12IN2 => 14,
    C12IN3 => 7,
    C2OUT => 6,
};

has timer_pins => {
    TMR0 => 17,
    TMR1 => 2,
    T0CKI => 17,
    T1CKI => 2,
    T1G => 3
};

has interrupt_pins => {
    INT => 17,
};

has usart_pins => {
    RX => 12,
    TX => 10,
    CK => 10,
    DT => 12,
};

has clock_pins => {
    CLKOUT => 3,
    CLKIN => 2,
};

has oscillator_pins => {
    OSC1 => 2,
    OSC2 => 3,
};

has icsp_pins => {
    ICSPCLK => 18,
    ICSPDAT => 19,
};

has selector_pins => {
    SS => 8, # SPI or I2C
};

has spi_pins => {
    SDI => 13, # SPI
    SCK => 11, # SPI
    SDO => 9, # SPI
};

has i2c_pins => {
    SDA => 13, # I2C
    SCL => 11, # I2C
};

has pwm_pins => {
    P1D => 14,
    P1C => 7,
    P1B => 6,
    P1A => 5,
};

has config => <<"...";
\t__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

...

has code_config => {
    debounce => {
        count => 5,
        delay => 1000, # in microseconds
    },
};

sub update_config {
    my ($self, $grp, $key, $val) = @_;
    return unless defined $grp;
    $self->code_config->{$grp} = {} unless exists $self->code_config->{$grp};
    my $grpref = $self->code_config->{$grp};
    if (ref $grpref eq 'HASH') {
        $grpref->{$key} = $val;
    } else {
        warn "Unsupported type for $grp\n";
    }
}

sub output_port {
    my ($self, $port, $pin) = @_;
    return undef unless $port =~ /^[A-C]$/;
    my $code = "clrf TRIS$port" if
        (not defined $pin or $pin > 7);
    $code = "bcf TRIS$port, TRIS$port$pin" if (defined $pin and $pin < 7);
    return << "...";
\tbanksel TRIS$port
\t$code
\tbanksel PORT$port
\tclrf PORT$port
...
}

sub port_value {
    my ($self, $port, $pin, $val) = @_;
    return undef unless $port =~ /^[A-C]$/;
    # if pin is not set set all values
    unless (defined $val or defined $pin) {
        return << "...";
\tclrf PORT$port
\tcomf PORT$port, 1
...
    }
    return "\tclrf PORT$port\n" unless defined $pin;
    if ($val =~ /^\d+$/) {
        return "\tbcf PORT$port, $pin\n" if "$val" eq '0';
        return "\tbsf PORT$port, $pin\n" if "$val" eq '1';
        return $self->assign_literal("PORT$port", $val);
    } else {
        # $val is a variable
        return $self->assign_variable("PORT$port", uc $val);
    }
}

sub analog_input_port {
    my ($self, $port, $pin) = @_;
    return undef unless $port =~ /^[A-C]$/;
    my $code = "clrf TRIS$port" if
        (not defined $pin or $pin > 7);
    $code = "bcf TRIS$port, TRIS$port$pin" if (defined $pin and $pin < 7);
    #TODO: find RA3 in the list of ports and adjust flags
    my $flags = sprintf "0x%2X", 0x00;
    return << "...";
\tbanksel TRIS$port
\t$code
\tbanksel ANSEL
\tmovlw $flags
\tmovwf ANSEL
\tbanksel PORT$port
...

}

sub digital_input_port {
    my ($self, $port, $pin) = @_;
    return undef unless $port =~ /^[A-C]$/;
    my $code = "clrf TRIS$port" if
        (not defined $pin or $pin > 7);
    $code = "bcf TRIS$port, TRIS$port$pin" if (defined $pin and $pin < 7);
    my $flags = sprintf "0x%2X", 0xFF;
    #TODO: find RA3 in the list of ports and adjust flags
    return << "...";
\tbanksel TRIS$port
\t$code
\tbanksel ANSEL
\tmovlw $flags
\tmovwf ANSEL
\tbanksel PORT$port
...

}

sub hang {
    my ($self, @args) = @_;
    return "\tgoto \$";
}

sub m_delay_var {
    return <<'...';
;;;;;; DELAY FUNCTIONS ;;;;;;;

DELAY_VAR_UDATA udata
DELAY_VAR   res 3

...
}

sub m_delay_us {
    return <<'...';
;; 1MHz => 1us per instruction
;; return, goto and call are 2us each
;; hence each loop iteration is 3us
;; the rest including movxx + return = 2us
;; hence usecs - 6 is used
m_delay_us macro usecs
    local _delay_usecs_loop_0
    variable usecs_1 = 0
if (usecs > D'6')
usecs_1 = usecs / D'3'
    movlw   usecs_1
    movwf   DELAY_VAR
_delay_usecs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delay_usecs_loop_0
else
    while usecs_1 < usecs
        nop
usecs_1++
    endw
endif
    endm
...
}

sub m_delay_ms {
    return <<'...';
;; 1MHz => 1us per instruction
;; each loop iteration is 3us each
;; there are 2 loops, one for (768 + 3) us
;; and one for the rest in ms
;; we add 3 instructions for the outer loop
;; number of outermost loops = msecs * 1000 / 771 = msecs * 13 / 10
m_delay_ms macro msecs
    local _delay_msecs_loop_0, _delay_msecs_loop_1
    variable msecs_1 = 0
msecs_1 = (msecs * D'13') / D'10'
    movlw   msecs_1
    movwf   DELAY_VAR + 1
_delay_msecs_loop_1:
    clrf   DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delay_msecs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delay_msecs_loop_0
    decfsz  DELAY_VAR + 1, F
    goto    _delay_msecs_loop_1
    endm
...
}

sub m_delay_s {
    return <<'...';
;; 1MHz => 1us per instruction
;; each loop iteration is 3us each
;; there are 2 loops, one for (768 + 3) us
;; and one for the rest in ms
;; we add 3 instructions for the outermost loop
;; 771 * 256 + 3 = 197379 ~= 200000
;; number of outermost loops = seconds * 1000000 / 200000 = seconds * 5
m_delay_s macro secs
    local _delay_secs_loop_0, _delay_secs_loop_1, _delay_secs_loop_2
    variable secs_1 = 0
secs_1 = secs * D'1000000' / D'197379'
    movlw   secs_1
    movwf   DELAY_VAR + 2
_delay_secs_loop_2:
    clrf    DELAY_VAR + 1   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_1:
    clrf    DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delay_secs_loop_0
    decfsz  DELAY_VAR + 1, F
    goto    _delay_secs_loop_1
    decfsz  DELAY_VAR + 2, F
    goto    _delay_secs_loop_2
    endm
...
}

sub delay {
    my ($self, $t) = @_;
    return '' if $t <= 0;
    # divide the time into component seconds, milliseconds and microseconds
    my $sec = POSIX::floor($t / 1e6);
    my $ms = POSIX::floor(($t - $sec * 1e6) / 1000);
    my $us = $t - $sec * 1e6 - $ms * 1000;
    my $code = '';
    my $funcs = {};
    my $macros = { m_delay_var => $self->m_delay_var };
    ## more than one function could be called so have them separate
    if ($sec > 0) {
        my $fn = "_delay_${sec}s";
        $code .= "\tcall $fn\n";
        $funcs->{$fn} = <<"....";
\tm_delay_s D'$sec'
\treturn
....
        $macros->{m_delay_s} = $self->m_delay_s;
    }
    if ($ms > 0) {
        my $fn = "_delay_${ms}ms";
        $code .= "\tcall $fn\n";
        $funcs->{$fn} = <<"....";
\tm_delay_ms D'$ms'
\treturn
....
        $macros->{m_delay_ms} = $self->m_delay_ms;
    }
    if ($us > 0) {
        my $fn = "_delay_${us}us";
        $code .= "\tcall $fn\n";
        $funcs->{$fn} = <<"....";
\tm_delay_us D'$us'
\treturn
....
        $macros->{m_delay_us} = $self->m_delay_us;
    }
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub ror {
    my ($self, $var, $bits) = @_;
    $var = uc $var;
    my $code = <<"...";
\tbcf STATUS, C
...
    for (1 .. $bits) {
        $code .= << "...";
\trrf $var, 1
\tbtfsc STATUS, C
\tbsf $var, 7
...
    }
    return $code;
}

sub assign_literal {
    my ($self, $var, $val) = @_;
    return "\tclrf $var\n" if "$val" eq '0';
    return <<"...";
\t;; moves $val to $var
\tmovlw D'$val'
\tmovwf $var
...
}

sub assign_variable {
    my ($self, $var1, $var2) = @_;
    return <<"...";
\t;; moves $var2 to $var1
\tmovf  $var2, 0
\tmovwf $var1
...
}

sub increment {
    my ($self, $var) = @_;
    return <<"..."
\t;; increments $var in place
\tincf $var, 1
...
}

sub decrement {
    my ($self, $var) = @_;
    return <<"..."
\t;; decrements $var in place
\tdecf $var, 1
...
}

sub m_debounce_var {
    return <<'...';
;;;;;; DEBOUNCE VARIABLES ;;;;;;;

DEBOUNCE_VAR_IDATA idata
;; initialize state to 1
DEBOUNCESTATE db 0x01
;; initialize counter to 0
DEBOUNCECOUNTER db 0x00

...
}
sub debounce {
    my ($self, $port, $pin, $action) = @_;
    my ($parent_label, $action_label);
    if ($action =~ /LABEL::(\w+)::\w+::\w+::(\w+)/) {
        $action_label = $1;
        $parent_label = $2;
    }
    return unless $action_label;
    return unless $parent_label;
    # incase the user does weird stuff override the count and delay
    my $debounce_count = $self->code_config->{debounce}->{count} || 1;
    my $debounce_delay = $self->code_config->{debounce}->{delay} || 1000;
    my ($deb_code, $funcs, $macros) = $self->delay($debounce_delay);
    $macros = {} unless defined $macros;
    $funcs = {} unless defined $funcs;
    $deb_code = 'nop' unless defined $deb_code;
    $macros->{m_debounce_var} = $self->m_debounce_var;
    my $code = <<"...";
\t;;; generate code for debounce $port<$pin>
$deb_code
\t;; has debounce state changed to down (bit 0 is 0)
\t;; if yes go to debounce-state-down
\tbtfsc   DEBOUNCESTATE, 0
\tgoto    _debounce_state_up
_debounce_state_down:
\tclrw
\tbtfss   PORT$port, $pin
\t;; increment and move into counter
\tincf    DEBOUNCECOUNTER, 0
\tmovwf   DEBOUNCECOUNTER
\tgoto    _debounce_state_check

_debounce_state_up:
\tclrw
\tbtfsc   PORT$port, $pin
\tincf    DEBOUNCECOUNTER, 0
\tmovwf   DEBOUNCECOUNTER
\tgoto    _debounce_state_check

_debounce_state_check:
\tmovf    DEBOUNCECOUNTER, W
\txorlw   $debounce_count
\t;; is counter == $debounce_count ?
\tbtfss   STATUS, Z
\tgoto    $parent_label
\t;; after $debounce_count straight, flip direction
\tcomf    DEBOUNCESTATE, 1
\tclrf    DEBOUNCECOUNTER
\t;; was it a key-down
\tbtfss   DEBOUNCESTATE, 0
\tgoto    $parent_label
\tgoto    $action_label
...
    return wantarray ? ($code, $funcs, $macros) : $code;
}
1;

=encoding utf8

=head1 NAME

VIC::PIC::P16F690

=head1 SYNOPSIS

A class that describes the code to be generated for each specific
microcontroller that maps the VIC syntax back into assembly. This is the
back-end to VIC's front-end.

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
