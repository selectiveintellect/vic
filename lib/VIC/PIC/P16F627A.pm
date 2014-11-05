package VIC::PIC::P16F627A;
use strict;
use warnings;
use bigint;

our $VERSION = '0.13';
$VERSION = eval $VERSION;

use Carp;
use POSIX ();
use Pegex::Base; # use this instead of Mo
extends 'VIC::PIC::Base';

has type => 'p16f627a';

has include => 'p16f627a.inc';

has org => 0;

has frequency => 4e6; # 4MHz

has address_range => [ 0x0000, 0x03FF ]; # 1K

has reset_address => 0x0000;

has isr_address => 0x0004;

has program_counter_size => 13; # PCL and PCLATH<4:0>

has stack_size => 8; # 8-level x 13-bit wide

has register_size => 8; # size of register W

has program_memory => 1024; # number of flash words

has data_memory => {
    SRAM => 224, # bytes
    EEPROM => 128, # bytes
};

has pin_counts => {
    total => 18, # 18 for DIP/SOIC, 20 for SSOP and 28 for QFN
    io => 16,
    adc => 0,
    comparator => 2,
    timer_8bit => 2,
    timer_16bit => 1,
    ssp => 0,
    pwm => 1,
    usart => 1,
};

has banks => {
    # general purpose registers
    gpr => [
        [ 0x20, 0x7F ],
        [ 0xA0, 0xEF ],
        [ 0x120, 0x14F ],
        [ ], # no GPRs in bank 4
    ],
    # special function registers
    sfr => [
        [ 0x00, 0x1F ],
        [ 0x80, 0x9F ],
        [ 0x100, 0x10B ],
        [ 0x180, 0x18B ],
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
    PORTA => [ 0 ],
    TRISA => [ 1 ],
    # 0x06
    PORTB => [ 0, 2 ],
    TRISB => [ 1, 3 ],
    # 0x0A
    PCLATH => [ 0 .. 3 ],
    # 0x0B
    INTCON => [ 0 .. 3 ],
    # 0x0C
    PIR1 => [ 0 ],
    PIE1 => [ 1 ],
    # 0x0E
    TMR1L => [ 0 ],
    PCON => [ 1 ],
    # 0x0F
    TMR1H => [ 0 ],
    # 0x10
    T1CON => [ 0 ],
    # 0x11
    TMR2 => [ 0 ],
    # 0x12
    T2CON => [ 0 ],
    PR2 => [ 1 ],
    # 0x15
    CCPR1L => [ 0 ],
    # 0x16
    CCPR1H => [ 0 ],
    # 0x17
    CCP1CON => [ 0 ],
    # 0x18
    RCSTA => [ 0 ],
    TXSTA => [ 1 ],
    # 0x19
    TXREG => [ 0 ],
    SPBRG => [ 1 ],
    # 0x1A
    RCREG => [ 0 ],
    EEDATA => [ 1 ],
    # 0x1B
    EEADR => [ 1 ],
    # 0x1C
    EECON1 => [ 1 ],
    # 0x1D
    EECON2 => [ 1 ],
    # 0x1F
    CMCON => [ 0 ],
    VRCON => [ 1 ],
};

has pins => {
    #name  #port  #portbit #pin
    RA2 => ['A', 2, 1],
    RA3 => ['A', 3, 2],
    RA4 => ['A', 4, 3],
    RA5 => ['A', 5, 4],
	Vss => [undef, undef, 5],
    RB0 => ['B', 0, 6],
    RB1 => ['B', 1, 7],
    RB2 => ['B', 2, 8],
    RB3 => ['B', 3, 9],
    RB4 => ['B', 4, 10],
    RB5 => ['B', 5, 11],
    RB6 => ['B', 6, 12],
    RB7 => ['B', 7, 13],
	Vdd => [undef, undef, 14],
    RA6 => ['A', 6, 15],
    RA7 => ['A', 7, 16],
    RA0 => ['A', 0, 17],
    RA1 => ['A', 1, 18],
};

has ports => {
    PORTA => 'A',
    PORTB => 'B',
    A => 'PORTA',
    B => 'PORTB',
};

has visible_pins => {
    1 => 'RA2',
    2 => 'RA3',
    3 => 'RA4',
    4 => 'RA5',
    5 => 'Vss',
    6 => 'RB0',
    7 => 'RB1',
    8 => 'RB2',
    9 => 'RB3',
    10 => 'RB4',
    11 => 'RB5',
    12 => 'RB6',
    13 => 'RB7',
    14 => 'Vdd',
    15 => 'RA6',
    16 => 'RA7',
    17 => 'RA0',
    18 => 'RA1',
};

has gpio_pins => {
    RA0 => 17,
    RA1 => 18,
    RA2 => 1,
    RA3 => 2,
    RA4 => 3,
    RA6 => 15,
    RA7 => 16,
    RB0 => 6,
    RB1 => 7,
    RB2 => 8,
    RB3 => 9,
    RB4 => 10,
    RB5 => 11,
    RB6 => 12,
    RB7 => 13,
    17 => 'RA0',
    19 => 'RA1',
    1 => 'RA2',
    2 => 'RA3',
    3 => 'RA4',
    4 => 'RA5',
    15 => 'RA6',
    16 => 'RA7',
    6 => 'RB0',
    7 => 'RB1',
    8 => 'RB2',
    9 => 'RB3',
    10 => 'RB4',
    11 => 'RB5',
    12 => 'RB6',
    13 => 'RB7',
};

has input_pins => {
    RA5 => 4,
    4 => 'RA5',
};

has power_pins => {
    Vdd => 14,
    Vss => 5,
    Vpp => 4,
    MCLR => 4,
    Vref => 1,
    14 => 'Vdd',
    5 => 'Vss',
    4 => 'Vpp',
    4 => 'MCLR',
    1 => 'Vref',
};

has adcs_bits  => {};

has analog_pins => {};

has comparator_pins => {
    CMP1 => 2,
    CMP2 => 3,
    2 => 'CMP1',
    3 => 'CMP2'
};

has analog_comparator_pins => {
    # analog comparator pins
    AN0  => 17,
    AN1  => 18,
    AN2  => 1,
    AN3  => 2,
    17 => 'AN0',
    18 => 'AN1',
    1 => 'AN2',
    2 => 'AN3',
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
    TMR0 => 3,
    TMR1 => 12,
    T0CKI => 3,
    T1CKI => 12,
    T1OSI => 13,
    T1OSO => 12,
    12 => 'T1OSO', # timer1 oscillator output
    13 => 'T1OSI', # timer1 oscillator input
    3 => 'TMR0',
    12 => 'TMR1',
    3 => 'T0CKI',
    12 => 'T1CKI',
};

has eint_pins => {
    INT => 6,
    6 => 'INT',
    RB0 => 6,
};

has ioc_pins => {
    RB4 => 10,
    RB5 => 11,
    RB6 => 12,
    RB7 => 13,
    10 => 'RB4',
    11 => 'RB5',
    12 => 'RB6',
    13 => 'RB7',
};

has usart_pins => {
    RX => 7,
    TX => 8,
    CK => 8,
    DT => 12,
    7 => 'RX',
    8 => 'TX',
    8 => 'CK',
    7 => 'DT',
};

has clock_pins => {
    CLKOUT => 15,
    CLKIN => 16,
    15 => 'CLKOUT',
    16 => 'CLKIN',
};

has oscillator_pins => {
    OSC1 => 16,
    OSC2 => 15,
    16 => 'OSC1',
    15 => 'OSC2',
};

has icsp_pins => {
    PGC => 12,
    PGD => 13,
    12 => 'PGC',
    13 => 'PGD',
    ICSPCLK => 12,
    ICSPDAT => 13,
    12 => 'ICSPCLK',
    13 => 'ICSPDAT',
    # low voltage programming pin
    PGM => 10,
    10 => 'PGM',
};

has selector_pins => {};

has spi_pins => {};

has i2c_pins => {};

#FIXME: PWM implementation should have a check for various modes supported
has pwm_pins => {
    CCP1 => 9,
    9 => 'CCP1',
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

VIC::PIC::P16F627A

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
