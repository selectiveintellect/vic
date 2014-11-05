package VIC::PIC::P16F690;
use strict;
use warnings;
use bigint;

our $VERSION = '0.13';
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

has program_memory => 4096; # number of flash words

has data_memory => {
    SRAM => 256, # bytes
    EEPROM => 256, # bytes
};

has pin_counts => {
    total => 20,
    io => 18,
    adc => 12,
    comparator => 2,
    timer_8bit => 2,
    timer_16bit => 1,
    ssp => 1,
    pwm => 1,
    usart => 1,
};

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
        [ 0x180, 0x19E ],
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
    SRCON => [ 3 ],
    # 0x1F
    ADCON0 => [ 0 ],
    ADCON1 => [ 1 ],
    ANSELH => [ 2 ],
};

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
    Vref => 18,
    1 => 'Vdd',
    20 => 'Vss',
    4 => 'Vpp',
    19 => 'ULPWU',
    4 => 'MCLR',
    18 => 'Vref',
};

has adcs_bits  => {
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

has eint_pins => {
    INT => 17,
    17 => 'INT',
    RA2 => 17,
};

has ioc_pins => {
    RA0 => 19,
    RA1 => 18,
    RA2 => 17,
    RA3 => 4,
    RA4 => 3,
    RA5 => 2,
    RB4 => 13,
    RB5 => 12,
    RB6 => 11,
    RB7 => 10,
    19 => 'RA0',
    18 => 'RA1',
    17 => 'RA2',
    4 => 'RA3',
    3 => 'RA4',
    2 => 'RA5',
    13 => 'RB4',
    12 => 'RB5',
    11 => 'RB6',
    10 => 'RB7',

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
