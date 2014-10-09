package VIC::PIC::P16F690;
use strict;
use warnings;
use bigint;

our $VERSION = '0.12';
$VERSION = eval $VERSION;

use Carp;
use POSIX ();
use Pegex::Base; # use this instead of Mo
extends 'VIC::PIC::Base';

has type => 'p16f690';

has include => 'p16f690.inc';

has org => 0;

has frequency => 4e6; # 4MHz

has address_range => [ 0x0000, 0x0FFF ]; # 4K

has reset_address => 0x0000;

has isr_address => 0x0004;

has program_counter_size => 13; # PCL and PCLATH<4:0>

has stack_size => 8; # 8-level x 13-bit wide

has register_size => 8; # size of register W

has banks => {
    # general purpose registers
    gpr => [
        [ 0x20, 0x7F ],
        [ 0xA0, 0xEF ],
        [ 0x120, 0x16F ],
        [ ], # no GPRs in bank 4
    ],
    # special function registers
    sfr => [
        [ 0x00, 0x1F ],
        [ 0x80, 0x9F ],
        [ 0x100, 0x11F ],
        [ 0x180, 0x19F ],
    ],
    bank_size => 0x80,
    common_bank => [ 0x70, 0x7F ],
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
    # 0.06
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
    #name  #port  #portbit #pin
	Vdd => [undef, undef, 1],
	RA5 => ['A', 5, 2],
	RA4 => ['A', 4, 3],
	RA3 => ['A', 3, 4],
	RC5 => ['C', 5, 5],
	RC4 => ['C', 4, 6],
	RC3 => ['C', 3, 7],
	RC6 => ['C', 6, 8],
	RC7 => ['C', 7, 9],
	RB7 => ['B', 7, 10],
	RB6 => ['B', 6, 11],
	RB5 => ['B', 5, 12],
	RB4 => ['B', 4, 13],
	RC2 => ['C', 2, 14],
	RC1 => ['C', 1, 15],
	RC0 => ['C', 0, 16],
	RA2 => ['A', 2, 17],
	RA1 => ['A', 1, 18],
	RA0 => ['A', 0, 19],
	Vss => [undef, undef, 20],
};

has ports => {
    PORTA => 'A',
    PORTB => 'B',
    PORTC => 'C',
    A => 'PORTA',
    B => 'PORTB',
    C => 'PORTC',
};

has visible_pins => {
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
    19 => 'RA0',
    18 => 'RA1',
    17 => 'RA2',
    3 => 'RA4',
    2 => 'RA5',
    16 => 'RC0',
    15 => 'RC1',
    14 => 'RC2',
    7 => 'RC3',
    6 => 'RC4',
    5 => 'RC5',
    8 => 'RC6',
    9 => 'RC7',
    13 => 'RB4',
    12 => 'RB5',
    11 => 'RB6',
    10 => 'RB7',
};

has input_pins => {
    RA3 => 4,
    4 => 'RA3',
};

has power_pins => {
    Vdd => 1,
    Vss => 20,
    Vpp => 4,
    ULPWU => 19,
    MCLR => 4,
    1 => 'Vdd',
    20 => 'Vss',
    4 => 'Vpp',
    19 => 'ULPWU',
    4 => 'MCLR',
};

has adcon1_scale  => {
    2 => '000',
    4 => '100',
    8 => '001',
    16 => '101',
    32 => '010',
    64 => '110',
    internal => '111',
};

has analog_pins => {
    # use ANSEL for pins AN0-AN7 and ANSELH for AN8-AN11
    #name   #pin    #portbit, #chsbits
    AN0  => [19, 0, '0000'],
    AN1  => [18, 1, '0001'],
    AN2  => [17, 2, '0010'],
    AN3  => [3,  3, '0011'],
    AN4  => [16, 4, '0100'],
    AN5  => [15, 5, '0101'],
    AN6  => [14, 6, '0110'],
    AN7  => [ 7, 7, '0111'],
    AN8  => [ 8, 8, '1000'],
    AN9  => [ 9, 9, '1001'],
    AN10 => [13, 10, '1010'],
    AN11 => [12, 12, '1011'],
    CVref => [undef, undef, '1100'],
    '0.6V' => [undef, undef, '1101'],
    #pin #name
    19 => 'AN0',
    18 => 'AN1',
    17 => 'AN2',
    3 => 'AN3',
    16 => 'AN4',
    15 => 'AN5',
    14 => 'AN6',
    7 => 'AN7',
    8 => 'AN8',
    9 => 'AN9',
    13 => 'AN10',
    12 => 'AN11',
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
    19 => 'C1IN',
    18 => 'C12IN0',
    17 => 'C1OUT',
    16 => 'C2IN',
    15 => 'C12IN1',
    14 => 'C12IN2',
    7 => 'C12IN3',
    6 => 'C2OUT',
};

has timer_prescaler => {
    2 => '000',
    4 => '001',
    8 => '010',
    16 => '011',
    32 => '100',
    64 => '101',
    128 => '110',
    256 => '111',
};

has wdt_prescaler => {
    1 => '000',
    2 => '001',
    4 => '010',
    8 => '011',
    16 => '100',
    32 => '101',
    64 => '110',
    128 => '111',
};

has timer_pins => {
    TMR0 => 17,
    TMR1 => 2,
    T0CKI => 17,
    T1CKI => 2,
    T1G => 3,
    17 => 'TMR0',
    2 => 'TMR1',
    17 => 'T0CKI',
    2 => 'T1CKI',
    3 => 'T1G',
};

has interrupt_pins => {
    INT => 17,
    17 => 'INT',
};

has usart_pins => {
    RX => 12,
    TX => 10,
    CK => 10,
    DT => 12,
    12 => 'RX',
    10 => 'TX',
    10 => 'CK',
    12 => 'DT',
};

has clock_pins => {
    CLKOUT => 3,
    CLKIN => 2,
    3 => 'CLKOUT',
    2 => 'CLKIN',
};

has oscillator_pins => {
    OSC1 => 2,
    OSC2 => 3,
    2 => 'OSC1',
    3 => 'OSC2',
};

has icsp_pins => {
    ICSPCLK => 18,
    ICSPDAT => 19,
    18 => 'ICSPCLK',
    19 => 'ICSPDAT',
};

has selector_pins => {
    SS => 8, # SPI or I2C
    8 => 'SS',
};

has spi_pins => {
    SDI => 13, # SPI
    SCK => 11, # SPI
    SDO => 9, # SPI
    13 => 'SDI',
    11 => 'SCK',
    9 => 'SDO',
};

has i2c_pins => {
    SDA => 13, # I2C
    SCL => 11, # I2C
    13 => 'SDA',
    11 => 'SCL',
};

has pwm_pins => {
    P1D => 14,
    P1C => 7,
    P1B => 6,
    P1A => 5,
    CCP1 => 5,
    14 => 'P1D',
    7 => 'P1C',
    6 => 'P1B',
    5 => 'P1A',
};

has chip_config => <<"...";
\t__config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)

...

has code_config => {
    debounce => {
        count => 5,
        delay => 1000, # in microseconds
    },
    adc => {
        right_justify => 1,
        vref => 0,
        internal => 0,
    },
    variable => {
        bits => 8, # bits. same as register_size
        export => 0, # do not export variables
    },
};

sub pwm_details {
    my ($self, $pwm_frequency, $duty, $type, @pins) = @_;
    no bigint;
    #pulse_width = $duty / $pwm_frequency;
    # timer2 prescaler
    my $prescaler = 1; # can be 1, 4 or 16
    # Tosc = 1 / Fosc
    my $f_osc = $self->frequency;
    my $pr2 = POSIX::ceil(($f_osc / 4) / $pwm_frequency); # assume prescaler = 1 here
    if (($pr2 - 1) <= 0xFF) {
        $prescaler = 1; # prescaler stays 1
    } else {
        $pr2 = POSIX::ceil($pr2 / 4); # prescaler is 4 or 16
        $prescaler = (($pr2 - 1) <= 0xFF) ? 4 : 16;
    }
    my $t2con = q{b'00000100'}; # prescaler is 1 or anything else
    $t2con = q{b'00000101'} if $prescaler == 4;
    $t2con = q{b'00000111'} if $prescaler == 16;
    # readjusting PR2 as per supported pre-scalers
    $pr2 = POSIX::ceil((($f_osc / 4) / $pwm_frequency) / $prescaler);
    $pr2--;
    $pr2 &= 0xFF;
    my $ccpr1l_ccp1con54 = POSIX::ceil(($duty * 4 * ($pr2 + 1)) / 100.0);
    my $ccp1con5 = ($ccpr1l_ccp1con54 & 0x02); #bit 5
    my $ccp1con4 = ($ccpr1l_ccp1con54 & 0x01); #bit 4
    my $ccpr1l = ($ccpr1l_ccp1con54 >> 2) & 0xFF;
    my $ccpr1l_x = sprintf "0x%02X", $ccpr1l;
    my $pr2_x = sprintf "0x%02X", $pr2;
    my $p1m = '00' if $type eq 'single';
    $p1m = '01' if $type eq 'full_forward';
    $p1m = '10' if $type eq 'half';
    $p1m = '11' if $type eq 'full_reverse';
    $p1m = '00' unless defined $p1m;
    my $ccp1con = sprintf "b'%s%d%d1100'", $p1m, $ccp1con5, $ccp1con4;
    my %str = (P1D => 0, P1C => 0, P1B => 0, P1A => 0); # default all are port pins
    my %trisc = ();
    foreach my $pin (@pins) {
        my $vpin = $self->convert_to_valid_pin($pin);
        unless ($vpin and exists $self->pins->{$vpin}) {
            carp "$pin is not a valid pin on the microcontroller. Ignoring\n";
            next;
        }
        my ($port, $portpin, $pinno) = @{$self->pins->{$vpin}};
        # the user may use say RC5 instead of CCP1 and we still want the
        # CCP1 name which should really be returned as P1A here
        my $pwm_pin = $self->pwm_pins->{$pinno};
        next unless defined $pwm_pin;
        # pulse steering only needed in Single mode
        $str{$pwm_pin} = 1 if $type eq 'single';
        $trisc{$portpin} = 1;
    }
    my $pstrcon = sprintf "b'0001%d%d%d%d'", $str{P1D}, $str{P1C}, $str{P1B}, $str{P1A};
    my $trisc_bsf = '';
    my $trisc_bcf = '';
    foreach (sort (keys %trisc)) {
        $trisc_bsf .= "\tbsf TRISC, TRISC$_\n";
        $trisc_bcf .= "\tbcf TRISC, TRISC$_\n";
    }
    my $pstrcon_code = '';
    if ($type eq 'single') {
        $pstrcon_code = << "...";
\tbanksel PSTRCON
\tmovlw $pstrcon
\tmovwf PSTRCON
...
    }
    return (
        # actual register values
        CCP1CON => $ccp1con,
        PR2 => $pr2_x,
        T2CON => $t2con,
        CCPR1L => $ccpr1l_x,
        PSTRCON => $pstrcon,
        PSTRCON_CODE => $pstrcon_code,
        # no ECCPAS
        PWM1CON => '0x80', # default
        # code to be added
        TRISC_BSF => $trisc_bsf,
        TRISC_BCF => $trisc_bcf,
        # general comments
        CCPR1L_CCP1CON54 => $ccpr1l_ccp1con54,
        FOSC => $f_osc,
        PRESCALER => $prescaler,
        PWM_FREQUENCY => $pwm_frequency,
        DUTYCYCLE => $duty,
        PINS => \@pins,
        TYPE => $type,
    );
}

sub pwm_code {
    my $self = shift;
    my %details = @_;
    my @pins = @{$details{PINS}};
    return << "...";
;;; PWM Type: $details{TYPE}
;;; PWM Frequency = $details{PWM_FREQUENCY} Hz
;;; Duty Cycle = $details{DUTYCYCLE} / 100
;;; CCPR1L:CCP1CON<5:4> = $details{CCPR1L_CCP1CON54}
;;; CCPR1L = $details{CCPR1L}
;;; CCP1CON = $details{CCP1CON}
;;; T2CON = $details{T2CON}
;;; PR2 = $details{PR2}
;;; PSTRCON = $details{PSTRCON}
;;; PWM1CON = $details{PWM1CON}
;;; Prescaler = $details{PRESCALER}
;;; Fosc = $details{FOSC}
;;; disable the PWM output driver for @pins by setting the associated TRIS bit
\tbanksel TRISC
$details{TRISC_BSF}
;;; set PWM period by loading PR2
\tbanksel PR2
\tmovlw $details{PR2}
\tmovwf PR2
;;; configure the CCP module for the PWM mode by setting CCP1CON
\tbanksel CCP1CON
\tmovlw $details{CCP1CON}
\tmovwf CCP1CON
;;; set PWM duty cycle
\tmovlw $details{CCPR1L}
\tmovwf CCPR1L
;;; configure and start TMR2
;;; - clear TMR2IF flag of PIR1 register
\tbanksel PIR1
\tbcf PIR1, TMR2IF
\tmovlw $details{T2CON}
\tmovwf T2CON
;;; enable PWM output after a new cycle has started
\tbtfss PIR1, TMR2IF
\tgoto \$ - 1
\tbcf PIR1, TMR2IF
;;; enable @pins pin output driver by clearing the associated TRIS bit
$details{PSTRCON_CODE}
;;; disable auto-shutdown mode
\tbanksel ECCPAS
\tclrf ECCPAS
;;; set PWM1CON if half bridge mode
\tbanksel PWM1CON
\tmovlw $details{PWM1CON}
\tmovwf PWM1CON
\tbanksel TRISC
$details{TRISC_BCF}
...
}

sub pwm_single {
    my ($self, $pwm_frequency, $duty, @pins) = @_;
    my %details = $self->pwm_details($pwm_frequency, $duty, 'single', @pins);
    # pulse steering automatically taken care of
    return $self->pwm_code(%details);
}

sub pwm_halfbridge {
    my ($self, $pwm_frequency, $duty, $deadband, @pins) = @_;
    # we ignore the @pins that comes in
    @pins = qw(P1A P1B);
    my %details = $self->pwm_details($pwm_frequency, $duty, 'half', @pins);
    # override PWM1CON
    if (defined $deadband and $deadband > 0) {
        my $fosc = $details{FOSC};
        my $pwm1con = $deadband * $fosc / 4e6; # $deadband is in microseconds
        $pwm1con &= 0x7F; # 6-bits only
        $pwm1con |= 0x80; # clear PRSEN bit
        $details{PWM1CON} = sprintf "0x%02X", $pwm1con;
    }
    return $self->pwm_code(%details);
}

sub pwm_fullbridge {
    my ($self, $direction, $pwm_frequency, $duty, @pins) = @_;
    my $type = 'full_forward';
    $type = 'full_reverse' if $direction =~ /reverse|backward|no?|0/i;
    # we ignore the @pins that comes in
    @pins = qw(P1A P1B P1C P1D);
    my %details = $self->pwm_details($pwm_frequency, $duty, $type, @pins);
    return $self->pwm_code(%details);
}

sub pwm_update {
    my ($self, $pwm_frequency, $duty) = @_;
    # hack into the existing functions to update only what we need
    my @pins = qw(P1A P1B P1C P1D);
    my %details = $self->pwm_details($pwm_frequency, $duty, 'single', @pins);
    my ($ccp1con5, $ccp1con4);
    $ccp1con4 = $details{CCPR1L_CCP1CON54} & 0x0001;
    $ccp1con5 = ($details{CCPR1L_CCP1CON54} >> 1) & 0x0001;
    if ($ccp1con4) {
        $ccp1con4 = "\tbsf CCP1CON, DC1B0";
    } else {
        $ccp1con4 = "\tbcf CCP1CON, DC1B0";
    }
    if ($ccp1con5) {
        $ccp1con5 = "\tbsf CCP1CON, DC1B1";
    } else {
        $ccp1con5 = "\tbcf CCP1CON, DC1B1";
    }
    return << "...";
;;; updating PWM duty cycle for a given frequency
;;; PWM Frequency = $details{PWM_FREQUENCY} Hz
;;; Duty Cycle = $details{DUTYCYCLE} / 100
;;; CCPR1L:CCP1CON<5:4> = $details{CCPR1L_CCP1CON54}
;;; CCPR1L = $details{CCPR1L}
;;; update CCPR1L and CCP1CON<5:4> or the DC1B[01] bits
$ccp1con4
$ccp1con5
\tmovlw $details{CCPR1L}
\tmovwf CCPR1L
...

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
