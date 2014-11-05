package VIC::PIC::P12F683;
use strict;
use warnings;
use bigint;

our $VERSION = '0.13';
$VERSION = eval $VERSION;

use Carp;
use POSIX ();
use Pegex::Base; # use this instead of Mo
extends 'VIC::PIC::Base';

has type => 'p12f683';

has include => 'p12f683.inc';

has org => 0;

has frequency => 4e6; # 4MHz

has address_range => [ 0x0000, 0x07FF ]; # 2K

has reset_address => 0x0000;

has isr_address => 0x0004;

has program_counter_size => 13; # PCL and PCLATH<4:0>

has stack_size => 8; # 8-level x 13-bit wide

has register_size => 8; # size of register W

has program_memory => 2048; # number of flash words

has data_memory => {
    SRAM => 128, # bytes
    EEPROM => 256, # bytes
};

has pin_counts => {
    total => 8,
    io => 6,
    adc => 4,
    comparator => 1,
    timer_8bit => 2,
    timer_16bit => 1,
    ssp => 0,
    pwm => 1,
    usart => 0,
};

has banks => {
    # general purpose registers
    gpr => [
        [ 0x20, 0x7F ],
        [ 0xA0, 0xBF ],
    ],
    # special function registers
    sfr => [
        [ 0x00, 0x1F ],
        [ 0x80, 0x9F ],
    ],
    bank_size => 0x80,
    common_bank => [ 0x70, 0x7F ],
};

has register_banks => {
    # 0x01
    TMR0 => [ 0 ],
    OPTION_REG => [ 1 ],
    # 0x02
    PCL => [ 0, 1 ],
    # 0x03
    STATUS => [ 0, 1 ],
    # 0x04
    FSR => [ 0, 1 ],
    # 0x05
    GPIO => [ 0 ],
    TRISIO => [ 1 ],
    # 0x0A
    PCLATH => [ 0, 1],
    # 0x0B
    INTCON => [ 0, 1 ],
    # 0x0C
    PIR1 => [ 0 ],
    PIE1 => [ 1 ],
    # 0x0E
    TMR1L => [ 0 ],
    PCON => [ 1 ],
    # 0x0F
    TMR1H => [ 0 ],
    OSCCON => [ 1 ],
    # 0x10
    T1CON => [ 0 ],
    OSCTUNE => [ 1 ],
    # 0x11
    TMR2 => [ 0 ],
    # 0x12
    T2CON => [ 0 ],
    PR2 => [ 1 ],
    # 0x13
    CCPR1L => [ 0 ],
    # 0x14
    CCPR1H => [ 0 ],
    # 0x15
    CCP1CON => [ 0 ],
    WPU => [ 1 ],
    # 0x16
    IOC => [ 1 ],
    # 0x18
    WDTCON => [ 0 ],
    # 0x19
    CMCON0 => [ 0 ],
    VRCON => [ 1 ],
    # 0x1A
    CMCON1 => [ 0 ],
    EEDAT => [ 1 ],
    # 0x1B
    EEADR => [ 1 ],
    # 0x1C
    EECON1 => [ 1 ],
    # 0x1D
    EECON2 => [ 1 ],
    # 0x1E
    ADRESH => [ 0 ],
    ADRESL => [ 1 ],
    # 0x1F
    ADCON0 => [ 0 ],
    ANSEL => [ 1 ],
};

has pins => {
    #name  #port  #portbit #pin
	Vdd => [undef, undef, 1],
    GP5 => ['', 5, 2],
	RA5 => ['A', 5, 2],
    GP4 => ['', 4, 3],
	RA4 => ['A', 4, 3],
	GP3 => ['', 3, 4],
	RA3 => ['A', 3, 4],
	GP2 => ['', 2, 5],
	RA2 => ['A', 2, 5],
	GP1 => ['', 1, 6],
	RA1 => ['A', 1, 6],
	GP0 => ['', 0, 7],
	RA0 => ['A', 0, 7],
	Vss => [undef, undef, 8],
};

# FIXME: PORTA == GPIO. have that switched as needed
has ports => {
    PORTA => 'A',
    A => 'PORTA',
    GPIO => 'PORTA',
};

has visible_pins => {
    1 => 'Vdd',
    2 => 'GP5',
    3 => 'GP4',
    4 => 'GP3',
    5 => 'GP2',
    6 => 'GP1',
    7 => 'GP0',
    8 => 'Vss',
};

has gpio_pins => {
    2 => 'GP5',
    3 => 'GP4',
    5 => 'GP2',
    6 => 'GP1',
    7 => 'GP0',
    GP0 => 7,
    GP1 => 6,
    GP2 => 5,
    GP4 => 3,
    GP5 => 2,
};

has input_pins => {
    GP3 => 4,
    4 => 'GP3',
};

has power_pins => {
    Vdd => 1,
    Vss => 8,
    Vpp => 4,
    ULPWU => 7,
    MCLR => 4,
    Vref => 6,
    1 => 'Vdd',
    8 => 'Vss',
    4 => 'Vpp',
    7 => 'ULPWU',
    4 => 'MCLR',
    6 => 'Vref',
};

has adcs_bits => {
    2 => '000',
    4 => '100',
    8 => '001',
    16 => '101',
    32 => '010',
    64 => '110',
    internal => '111',
};

has analog_pins => {
    # use ANSEL for pins AN0-AN3
    #name   #pin    #portbit, #chsbits
    AN0  => [7, 0, '00'],
    AN1  => [6, 1, '01'],
    AN2  => [5, 2, '10'],
    AN3  => [3, 3, '11'],
    #pin #name
    7 => 'AN0',
    6 => 'AN1',
    5 => 'AN2',
    3 => 'AN3',
};

has comparator_pins => {
    'CIN+' => 7, #FIXME: does grammar support this ? what about other PICs
    'CIN-' => 6,
    COUT => 5,
    7 => 'CIN+',
    6 => 'CIN-',
    5 => 'COUT',
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
    TMR0 => 5,
    TMR1 => 2,
    T0CKI => 5,
    T1CKI => 2,
    T1G => 3,
    5 => 'TMR0',
    2 => 'TMR1',
    5 => 'T0CKI',
    2 => 'T1CKI',
    3 => 'T1G',
};

has eint_pins => {
    INT => 5,
    5 => 'INT',
    GP2 => 5,
};

has ioc_pins => {
    GP0 => 7,
    GP1 => 6,
    GP2 => 5,
    GP3 => 4,
    GP4 => 3,
    GP5 => 2,
    7 => 'GP0',
    6 => 'GP1',
    5 => 'GP2',
    4 => 'GP3',
    3 => 'GP4',
    2 => 'GP5',
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
    ICSPCLK => 6,
    ICSPDAT => 7,
    6 => 'ICSPCLK',
    7 => 'ICSPDAT',
};

#FIXME: handle PWM functionality
has pwm_pins => {
    CCP1 => 5,
    5 => 'CCP1',
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

VIC::PIC::P12F683

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
