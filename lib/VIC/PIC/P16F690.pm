package VIC::PIC::P16F690;
use strict;
use warnings;
use Moo;
extends 'VIC::PIC::Functions'; # to be renamed

# role CodeGen
has type => (is => 'ro', default => 'p16f690');
has include => (is => 'ro', default => 'p16f690.inc');
has org => (is => 'ro', default => 0);
##TODO: allow adjusting of this based on user input. for now fixed to this
#string
has chip_config => (is => 'rw', default => sub {
        return <<"...";
        __config (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF)
...
});
has code_config => (is => 'rw', default => sub {
        {
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
        }
});

#role Chip
has f_osc => (is => 'ro', default => 4e6); # 4MHz internal oscillator
has pcl_size => (is => 'ro', default => 13); # program counter (PCL) size
has stack_size => (is => 'ro', default => 8); # 8 levels of 13-bit entries
has wreg_size => (is => 'ro', default => 8); # 8-bit register WREG
# all memory is in bytes
has memory => (is => 'ro', default => sub { {flash => 4096 * 2, SRAM => 256, EEPROM => 256} });
has address => (is => 'ro', default => sub { {isr => [ 0x0004 ], reset => [ 0x0000 ], range => [ 0x0000, 0x0FFF ] }});

has pin_counts => (is => 'ro', default => sub { {
    pdip => 20, ## PDIP or DIP ?
    soic => 20,
    ssop => 20,
    total => 20,
    io => 18,
    adc => 12,
    comparator => 2,
    timer_8bit => 2,
    timer_16bit => 1,
    ssp => 1,
    pwm => 1,
    usart => 1,
}});

has banks => (is => 'ro', default => sub {
    {
        count => 4,
        size => 0x80,
        gpr => {
            0 => [ 0x020, 0x07F],
            1 => [ 0x0A0, 0x0EF],
            2 => [ 0x120, 0x16F],
            3 => [ 0x1A0, 0x1EF],
        },
        # remapping of these addresses automatically done by chip
        remap => {
            [0x070, 0x07F] => [
                [0x0F0, 0x0FF],
                [0x170, 0x17F],
                [0x1F0, 0x1FF],
            ],
        },
    }
});

has registers => (is => 'ro', default => sub {
    {
        INDF => [0x000, 0x080, 0x100, 0x180], # indirect addressing
        TMR0 => [0x001, 0x101],
        OPTION_REG => [0x081, 0x181],
        PCL => [0x002, 0x082, 0x102, 0x182],
        STATUS => [0x003, 0x083, 0x103, 0x183],
        FSR => [0x004, 0x084, 0x104, 0x184],
        PORTA => [0x005, 0x105],
        TRISA => [0x085, 0x185],
        PORTB => [0x006, 0x106],
        TRISB => [0x086, 0x186],
        PORTC => [0x007, 0x107],
        TRISC => [0x087, 0x187],
        PCLATH => [0x00A, 0x08A, 0x10A, 0x18A],
        INTCON => [0x00B, 0x08B, 0x10B, 0x18B],
        PIR1 => [0x00C],
        PIE1 => [0x08C],
        EEDAT => [0x10C],
        EECON1 => [0x18C],
        PIR2 => [0x00D],
        PIE2 => [0x08D],
        EEADR => [0x10D],
        EECON2 => [0x18D], # not addressable apparently
        TMR1L => [0x00E],
        PCON => [0x08E],
        EEDATH => [0x10E],
        TMR1H => [0x00F],
        OSCCON => [0x08F],
        EEADRH => [0x10F],
        T1CON => [0x010],
        OSCTUNE => [0x090],
        TMR2 => [0x011],
        T2CON => [0x012],
        PR2 => [0x092],
        SSPBUF => [0x013],
        SSPADD => [0x093],
        SSPCON => [0x014],
        SSPSTAT => [0x094],
        CCPR1L => [0x015],
        WPUA => [0x095],
        WPUB => [0x115],
        CCPR1H => [0x016],
        IOCA => [0x096],
        IOCB => [0x116],
        CCP1CON => [0x017],
        WDTCON => [0x097],
        RCSTA => [0x018],
        TXSTA => [0x098],
        VRCON => [0x118],
        TXREG => [0x019],
        SPBRG => [0x099],
        CM1CON0 => [0x119],
        RCREG => [0x01A],
        SPBRGH => [0x09A],
        CM2CON0 => [0x11A],
        BAUDCTL => [0x09B],
        CM2CON1 => [0x11B],
        PWM1CON => [0x01C],
        ECCPAS => [0x01D],
        PSTRCON => [0x19D],
        ADRESH => [0x01E],
        ADRESL => [0x09E],
        ANSEL => [0x11E],
        SRCON => [0x19E],
        ADCON0 => [0x01F],
        ADCON1 => [0x09F],
        ANSELH => [0x11F],
    }
});

has pins => (is => 'ro', default => sub {
    {
        # number to pin name and pin name to number
        1 => [qw(Vdd)],
        Vdd => 1,
        2 => [qw(RA5 T1CKI OSC1 CLKIN)],
        RA5 => 2,
        T1CKI => 2,
        OSC1 => 2,
        CLKIN => 2,
        3 => [qw(RA4 AN3 TIG OSC2 CLKOUT)],
        RA4 => 3,
        AN3 => 3,
        TIG => 3,
        OSC2 => 3,
        CLKOUT => 3,
        4 => [qw(RA3 MCLR Vpp)],
        RA3 => 4,
        MCLR => 4,
        Vpp => 4,
        5 => [qw(RC5 CCP1 P1A)],
        RC5 => 5,
        CCP1 => 5,
        P1A => 5,
        6 => [qw(RC4 C2OUT P1B)],
        RC4 => 6,
        C2OUT => 6,
        P1B => 6,
        7 => [qw(RC3 AN7 C12IN3- P1C)],
        RC3 => 7,
        AN7 => 7,
        'C12IN3-' => 7,
        P1C => 7,
        8 => [qw(RC6 AN8 SS)],
        RC6 => 8,
        AN8 => 8,
        SS => 8,
        9 => [qw(RC7 AN9 SDO)],
        RC7 => 9,
        AN9 => 9,
        SDO => 9,
        10 => [qw(RB7 TX CK)],
        RB7 => 10,
        TX => 10,
        CK => 10,
        11 => [qw(RB6 SCK SCL)],
        RB6 => 11,
        SCK => 11,
        SCL => 11,
        12 => [qw(RB5 AN11 RX DT)],
        RB5 => 12,
        AN11 => 12,
        RX => 12,
        DT => 12,
        13 => [qw(RB4 AN10 SDI SDA)],
        RB4 => 13,
        AN10 => 13,
        SDI => 13,
        SDA => 13,
        14 => [qw(RC2 AN6 C12IN2- P1D)],
        RC2 => 14,
        AN6 => 14,
        'C12IN2-' => 14,
        P1D => 14,
        15 => [qw(RC1 AN5 C12IN1-)],
        RC1 => 15,
        AN5 => 15,
        'C12IN1-' => 15,
        16 => [qw(RC0 AN4 C2IN+)],
        RC0 => 16,
        AN4 => 16,
        'C2IN+' => 16,
        17 => [qw(RA2 AN2 T0CKI INT C1OUT)],
        RA2 => 17,
        AN2 => 17,
        T0CKI => 17,
        INT => 17,
        C1OUT => 17,
        18 => [qw(RA1 AN1 C12IN0- Vref ICSPCLK)],
        RA1 => 18,
        AN1 => 18,
        'C12IN0-' => 18,
        Vref => 18,
        ICSPCLK => 18,
        19 => [qw(RA0 AN0 C1N+ ICSPDAT ULPWU)],
        RA0 => 19,
        AN0 => 19,
        'C1N+' => 19,
        ICSPDAT => 19,
        ULPWU => 19,
        20 => [qw(Vss)],
        Vss => 20,
    }
});

has gpio_ports => (is => 'ro', default => sub {
    [qw(PORTA PORTB PORTC)]
});
# bidirectional
has gpio_pins => (is => 'ro', default => sub {
    {
        #I/O => [port, tristate, bit]
        RA0 => ['PORTA', 'TRISA', 0],
        RA1 => ['PORTA', 'TRISA', 1],
        RA2 => ['PORTA', 'TRISA', 2],
        RA4 => ['PORTA', 'TRISA', 4],
        RA5 => ['PORTA', 'TRISA', 5],
        RB4 => ['PORTB', 'TRISB', 4],
        RB5 => ['PORTB', 'TRISB', 5],
        RB6 => ['PORTB', 'TRISB', 6],
        RB7 => ['PORTB', 'TRISB', 7],
        RC0 => ['PORTC', 'TRISC', 0],
        RC1 => ['PORTC', 'TRISC', 1],
        RC2 => ['PORTC', 'TRISC', 2],
        RC3 => ['PORTC', 'TRISC', 3],
        RC4 => ['PORTC', 'TRISC', 4],
        RC5 => ['PORTC', 'TRISC', 5],
        RC6 => ['PORTC', 'TRISC', 6],
        RC7 => ['PORTC', 'TRISC', 7],
    },
});

has input_pins => (is => 'ro', default => sub {
    {
        #I/O => [port, tristate, bit]
        RA3 => ['PORTA', 'TRISA', 3],
    }
});

has output_pins => (is => 'ro', default => undef);

my @roles = map ("VIC::PIC::Roles::$_", qw(CodeGen Chip GPIO));
with @roles;

1;
__END__
package VIC::PIC::P16F690_old;
use strict;
use warnings;
use bigint;

our $VERSION = '0.13';
$VERSION = eval $VERSION;

use Carp;
use POSIX ();
use Pegex::Base; # use this instead of Mo
extends 'VIC::PIC::Base';

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
