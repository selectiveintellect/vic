package VIC::PIC::P18F252;
use strict;
use warnings;
use bigint;

our $VERSION = '0.13';
$VERSION = eval $VERSION;

use Carp;
use POSIX ();
use Pegex::Base; # use this instead of Mo
extends 'VIC::PIC::Base';

has type => 'p18f252';

has include => 'p18f252.inc';

has org => 0;

has frequency => 4e6; # 4MHz

has address_range => [ 0x0000, 0x0FFF ]; # 4K

has reset_address => 0x00000;

has isr_address => {
    high => 0x0008,
    low => 0x0018
}; #TODO: handle multiple

has program_counter_size => 21; # PC<20:0> - PCL,PCLATH,PCLATU

has stack_size => 31; # 31-level x 21-bit wide

has register_size => 8; # size of register W

has program_memory => 16384; # number of flash words

has data_memory => {
    SRAM => 1536, # bytes
    EEPROM => 256, # bytes
};

has pin_counts => {
    total => 28, # DIP/SOIC only.
    io => 22,
    adc => 5,
    comparator => 0,
    timer_8bit => 1,
    timer_16bit => 3,
    ssp => 1,
    pwm => 2,
    usart => 1,
    psp => 0, # parallel slave port
};

has banks => {
    # general purpose registers
    gpr => [
    ],
    # special function registers
    sfr => [
    ],
    bank_size => 0,
    common_bank => [],
};

has register_address => {
    TOSU => 0xFFF,
    TOSH => 0xFFE,
    TOSL => 0xFFD,
    STKPTR => 0xFFC,
    PCLATU => 0xFFB,
    PCLATH => 0xFFA,
    PCL => 0xFF9,
    TBLPTRU => 0xFF8,
    TBLPTRH => 0xFF7,
    TBLPTRL => 0xFF6,
    TABLAT => 0xFF5,
    PRODH => 0xFF4,
    PRODL => 0xFF3,
    INTCON => 0xFF2,
    INTCON2 => 0xFF1,
    INTCON3 => 0xFF1,
    INDF0 => 0xFEF,
    POSTINC0 => 0xFEE,
    POSTDEC0 => 0xFED,
    PREINC0 => 0xFEC,
    PLUSW0 => 0xFEB,
    FSR0H => 0xFEA,
    FSR0L => 0xFE9,
    WREG => 0xFE8,
    INDF1 => 0xFE7,
    POSTINC1 => 0xFE6,
    POSTDEC1 => 0xFE5,
    PREINC1 => 0xFE4,
    PLUSW1 => 0xFE3,
    FSR1H => 0xFE2,
    FSR1L => 0xFE1,
    BSR => 0xFE0,
    INDF2 => 0xFDF,
    POSTINC2 => 0xFDE,
    POSTDEC2 => 0xFDD,
    PREINC2 => 0xFDC,
    PLUSW2 => 0xFDB,
    FSR2H => 0xFDA,
    FSR2L => 0xFD9,
    STATUS => 0xFD8,
    TMR0H => 0xFD7,
    TMR0L => 0xFD6,
    T0CON => 0xFD5,
    OSCCON => 0xFD3,
    LVDCON => 0xFD2,
    WDTCON => 0xFD1,
    RCON => 0xFD0,
    TMR1H => 0xFCF,
    TMR1L => 0xFCE,
    T1CON => 0xFCD,
    TMR2 => 0xFCC,
    PR2 => 0xFCB,
    T2CON => 0xFCA,
    SSPBUF => 0xFC9,
    SSPADD => 0xFC8,
    SSPSTAT => 0xFC7,
    SSPCON1 => 0xFC6,
    SSPCON2 => 0xFC5,
    ADRESH => 0xFC4,
    ADRESL => 0xFC3,
    ADCON0 => 0xFC2,
    ADCON1 => 0xFC1,
    CCPR1H => 0xFBF,
    CCPR1L => 0xFBE,
    CCP1CON => 0xFBD,
    CCPR2H => 0xFBC,
    CCPR2L => 0xFBB,
    CCP2CON => 0xFBA,
    TMR3H => 0xFB3,
    TMR3L => 0xFB2,
    T3CON => 0xFB1,
    SPBRG => 0xFAF,
    RCREG => 0xFAE,
    TXREG => 0xFAD,
    TXSTA => 0xFAC,
    RCSTA => 0xFAB,
    EEADR => 0xFA9,
    EEDATA => 0xFA8,
    EECON2 => 0xFA7,
    EECON1 => 0xFA6,
    IPR2 => 0xFA2,
    PIR2 => 0xFA1,
    PIE2 => 0xFA0,
    IPR1 => 0xF9F,
    PIR1 => 0xF9E,
    PIE1 => 0xF9D,
    TRISC => 0xF94,
    TRISB => 0xF93,
    TRISA => 0xF92,
    LATC => 0xF8B,
    LATB => 0xF8A,
    LATA => 0xF89,
    PORTC => 0xF82,
    PORTB => 0xF81,
    PORTA => 0xF80,
};

has register_banks => {};

has pins => {
    #name  #port  #portbit #pin
	Vdd => [undef, undef, 20],
    RA0 => ['A', 0, 2],
    RA1 => ['A', 1, 3],
    RA2 => ['A', 2, 4],
    RA3 => ['A', 3, 5],
    RA4 => ['A', 4, 6],
    RA5 => ['A', 5, 7],
    RA6 => ['A', 6, 10],
    RB0 => ['B', 0, 21], 
    RB1 => ['B', 1, 22], 
    RB2 => ['B', 2, 23], 
    RB3 => ['B', 3, 24], 
    RB4 => ['B', 4, 25], 
    RB5 => ['B', 5, 26], 
    RB6 => ['B', 6, 27], 
    RB7 => ['B', 7, 28], 
    RC0 => ['C', 0, 11],
    RC1 => ['C', 1, 12],
    RC2 => ['C', 2, 13],
    RC3 => ['C', 3, 14],
    RC4 => ['C', 4, 15],
    RC5 => ['C', 5, 16],
    RC6 => ['C', 6, 17],
    RC7 => ['C', 7, 18],
    #TODO: handle duplicate values of pins in code
	Vss => [undef, undef, [19, 8]],
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
    1 => 'MCLR',
    2 => 'RA0',
    3 => 'RA1',
    4 => 'RA2',
    5 => 'RA3',
    6 => 'RA4',
    7 => 'RA5',
    8 => 'Vss',
    9 => 'OSC1',
    10 => 'RA6',
    11 => 'RC0',
    12 => 'RC1',
    13 => 'RC2',
    14 => 'RC3',
    15 => 'RC4',
    16 => 'RC5',
    17 => 'RC6',
    18 => 'RC7',
    19 => 'Vss',
    20 => 'Vdd',
    21 => 'RB0',
    22 => 'RB1',
    23 => 'RB2',
    24 => 'RB3',
    25 => 'RB4',
    26 => 'RB5',
    27 => 'RB6',
    28 => 'RB7',
};

has gpio_pins => {
    RA0 => 2,
    RA1 => 3,
    RA2 => 4,
    RA3 => 5,
    RA4 => 6,
    RA5 => 7,
    RA6 => 10,
    RC0 => 11,
    RC1 => 12,
    RC2 => 13,
    RC3 => 14,
    RC4 => 15,
    RC5 => 16,
    RC6 => 17,
    RC7 => 18,
    RB0 => 21,
    RB1 => 22,
    RB2 => 23,
    RB3 => 24,
    RB4 => 25,
    RB5 => 26,
    RB6 => 27,
    RB8 => 28,
    2 => 'RA0',
    3 => 'RA1',
    4 => 'RA2',
    5 => 'RA3',
    6 => 'RA4',
    7 => 'RA5',
    10 => 'RA6',
    11 => 'RC0',
    12 => 'RC1',
    13 => 'RC2',
    14 => 'RC3',
    15 => 'RC4',
    16 => 'RC5',
    17 => 'RC6',
    18 => 'RC7',
    21 => 'RB0',
    22 => 'RB1',
    23 => 'RB2',
    24 => 'RB3',
    25 => 'RB4',
    26 => 'RB5',
    27 => 'RB6',
    28 => 'RB7',
};

has input_pins => {};

has power_pins => {
    Vdd => 20,
    Vss => [19, 8], #TODO: handle multiple ?
    Vpp => 1,
    LVDIN => 7,
    MCLR => 1,
    'Vref+' => 5,
    'Vref-' => 4,
    20 => 'Vdd',
    19 => 'Vss',
    8 => 'Vss',
    1 => 'Vpp',
    7 => 'LVDIN',
    1 => 'MCLR',
    5 => 'Vref+',
    4 => 'Vref-',
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
    AN0  => [2, 0, '0000'],
    AN1  => [3, 1, '0001'],
    AN2  => [4, 2, '0010'],
    AN3  => [5, 3, '0011'],
    AN4  => [7, 4, '0100'],
#    CVref => [undef, undef, '1100'],
#    '0.6V' => [undef, undef, '1101'],
    #pin #name
    2 => 'AN0',
    3 => 'AN1',
    4 => 'AN2',
    5 => 'AN3',
    7 => 'AN4',
};

has comparator_pins => {};

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
    T1OSO => 11,
    T1CKI => 11,
    11 => 'T1CKI',
    T1OSI => 12,
    12 => 'T1OSI',
    TMR1 => 11,
    T0CKI => 6,
    6 => 'T0CKI',
    TMR0 => 6,
};

has eint_pins => {
    INT0 => 21,
    21 => 'INT0',
    INT1 => 22,
    22 => 'INT1',
    INT2 => 23,
    23 => 'INT2',
    RB0 => 21,
    RB1 => 22,
    RB2 => 23,
};

has ioc_pins => {
    RB4 => 25,
    25 => 'RB4',
    RB5 => 26,
    26 => 'RB5',
    RB6 => 27,
    27 => 'RB6',
    RB7 => 28,
    28 => 'RB7',
};

has usart_pins => {
    RX => 18,
    TX => 17,
    CK => 17,
    DT => 18,
    18 => 'RX',
    17 => 'TX',
};

has clock_pins => {
    CLKOUT => 10,
    CLKIN => 9,
    10 => 'CLKOUT',
    9 => 'CLKIN',
    # alias
    CLKI => 'CLKIN',
    CLKOUT => 'CLKO',
};

has oscillator_pins => {
    OSC1 => 9,
    OSC2 => 10,
    9 => 'OSC1',
    10 => 'OSC2',
};

has icsp_pins => {
    PGM => 26,
    26 => 'PGM', # programming enable
    ICSPEN => 'PGM',
    PGC => 27,
    27 => 'PGC', # programming clock
    ICSPCLK => 'PGC',
    PGD => 28,
    28 => 'PGD', # programming data
    ICSPDAT => 'PGD',
};

has selector_pins => {
    SS => 7, # SPI or I2C
    7 => 'SS',
};

has spi_pins => {
    SDI => 15, # SPI
    SCK => 14, # SPI
    SDO => 16, # SPI
    15 => 'SDI',
    14 => 'SCK',
    16 => 'SDO',
};

has i2c_pins => {
    SDA => 15, # I2C
    SCL => 14, # I2C
    15 => 'SDA',
    14 => 'SCL',
};

has pwm_pins => {
    CCP2 => [12, 24], # multiple pins multiplexed
    24 => 'CCP2',
    12 => 'CCP2',
    CCP1 => 13,
    13 => 'CCP1',
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

VIC::PIC::P18F252

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
