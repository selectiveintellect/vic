package VIC::PIC::P16F687;
use strict;
use warnings;
use Moo;
extends 'VIC::PIC::Base';

# role CodeGen
has type => (is => 'ro', default => 'p16f687');
has include => (is => 'ro', default => 'p16f687.inc');
has org => (is => 'ro', default => 0);
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
has memory => (is => 'ro', default => sub {
    {
        flash => 2048, # words
        SRAM => 128,
        EEPROM => 256,
    }
});
has address => (is => 'ro', default => sub {
    {
        isr => [ 0x0004 ],
        reset => [ 0x0000 ],
        range => [ 0x0000, 0x07FF ],
    }
});

has pin_counts => (is => 'ro', default => sub { {
    pdip => 20, ## PDIP or DIP ?
    soic => 20,
    ssop => 20,
    total => 20,
    io => 18,
}});

has banks => (is => 'ro', default => sub {
    {
        count => 4,
        size => 0x80,
        gpr => {
            0 => [ 0x020, 0x07F],
            1 => [ 0x0A0, 0x0BF],
            2 => [],
            3 => [],
        },
        # remapping of these addresses automatically done by chip
        common => [0x070, 0x07F],
        remap => [
            [0x0F0, 0x0FF],
            [0x170, 0x17F],
            [0x1F0, 0x1FF],
        ],
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
        TMR1H => [0x00F],
        OSCCON => [0x08F],
        T1CON => [0x010],
        OSCTUNE => [0x090],
        SSPBUF => [0x013],
        SSPADD => [0x093],
        SSPCON => [0x014],
        SSPSTAT => [0x094],
        WPUA => [0x095],
        WPUB => [0x115],
        IOCA => [0x096],
        IOCB => [0x116],
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
        5 => [qw(RC5)],
        RC5 => 5,
        6 => [qw(RC4 C2OUT)],
        RC4 => 6,
        C2OUT => 6,
        7 => [qw(RC3 AN7 C12IN3-)],
        RC3 => 7,
        AN7 => 7,
        'C12IN3-' => 7,
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
        14 => [qw(RC2 AN6 C12IN2-)],
        RC2 => 14,
        AN6 => 14,
        'C12IN2-' => 14,
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

has clock_pins => (is => 'ro', default => sub {
    {
        CLKOUT => 3,
        CLKIN => 2,
    }
});

has oscillator_pins => (is => 'ro', default => sub {
    {
        OSC1 => 2,
        OSC2 => 3,
    }
});

has program_pins => (is => 'ro', default => sub {
    {
        clock => 'ICSPCLK',
        data => 'ICSPDAT',
    }
});

has io_ports => (is => 'ro', default => sub {
    {
        #port => tristate,
        PORTA => 'TRISA',
        PORTB => 'TRISB',
        PORTC => 'TRISC',
    }
});

has input_pins => (is => 'ro', default => sub {
    {
        #I/O => [port, tristate, bit]
        RA0 => ['PORTA', 'TRISA', 0],
        RA1 => ['PORTA', 'TRISA', 1],
        RA2 => ['PORTA', 'TRISA', 2],
        RA3 => ['PORTA', 'TRISA', 3], # input only
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
    }
});

has output_pins => (is => 'ro', default => sub {
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
    }
});

has analog_pins => (is => 'ro', default => sub {
        {
            # use ANSEL for pins AN0-AN7 and ANSELH for AN8-AN11
            #pin => number, bit
            AN0  => [19, 0],
            AN1  => [18, 1],
            AN2  => [17, 2],
            AN3  => [3,  3],
            AN4  => [16, 4],
            AN5  => [15, 5],
            AN6  => [14, 6],
            AN7  => [ 7, 7],
            AN8  => [ 8, 8],
            AN9  => [ 9, 9],
            AN10 => [13, 10],
            AN11 => [12, 12],
        }
});

has adc_channels => (is => 'ro', default => 12);
has adcs_bits  => (is => 'ro', default => sub {
    {
        2 => '000',
        4 => '100',
        8 => '001',
        16 => '101',
        32 => '010',
        64 => '110',
        internal => '111',
    }
});
has adc_chs_bits => (is => 'ro', default => sub {
        {
            #pin => chsbits
            AN0  => '0000',
            AN1  => '0001',
            AN2  => '0010',
            AN3  => '0011',
            AN4  => '0100',
            AN5  => '0101',
            AN6  => '0110',
            AN7  => '0111',
            AN8  => '1000',
            AN9  => '1001',
            AN10 => '1010',
            AN11 => '1011',
            CVref => '1100',
            '0.6V' => '1101',
        }
});

has timer_prescaler => (is => 'ro', default => sub {
    {
        2 => '000',
        4 => '001',
        8 => '010',
        16 => '011',
        32 => '100',
        64 => '101',
        128 => '110',
        256 => '111',
    }
});

has wdt_prescaler => (is => 'ro', default => sub {
    {
        1 => '000',
        2 => '001',
        4 => '010',
        8 => '011',
        16 => '100',
        32 => '101',
        64 => '110',
        128 => '111',
    }
});

has timer_pins => (is => 'ro', default => sub {
    {
        TMR0 => 'TMR0',
        TMR1 => ['TMR1H', 'TMR1L'],
        T0CKI => 17,
        T1CKI => 2,
        T1G => 3,
    }
});

#external interrupt
has eint_pins => (is => 'ro', default => sub {
    {
        INT => 17,
    }
});

has ioc_pins => (is => 'ro', default => sub {
    {
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
    }
});

has usart_pins => (is => 'ro', default => sub {
    {
        async_in => 'RX',
        async_out => 'TX',
        sync_clock => 'CK',
        sync_data => 'DT',
    }
});

has selector_pins => (is => 'ro', default => sub {
    {
        'spi_or_i2c' => 'SS',
    }
});

has spi_pins => (is => 'ro', default => sub {
    {
        data_out => 'SDO',
        data_in => 'SDI',
        clock => 'SCK',
    }
});

has i2c_pins => (is => 'ro', default => sub {
    {
        data => 'SDA',
        clock => 'SCL',
    }
});

has cmp_input_pins => (is => 'ro', default => sub {
    {
        'C1IN+' => 'C1IN+',
        'C12IN0-' => 'C12IN0-',
        'C2IN+' => 'C2IN+',
        'C12IN1-' => 'C12IN1-',
        'C12IN2-' => 'C12IN2-',
        'C12IN3-' => 'C12IN3-',
    }
});

has cmp_output_pins => (is => 'ro', default => sub {
    {
        C1OUT => 'C1OUT',
        C2OUT => 'C2OUT',
    }
});

my @rolenames = qw(CodeGen Operators Chip GPIO ADC ISR Timer Operations USART
SPI I2C Comparator);
my @roles = map (("VIC::PIC::Roles::$_", "VIC::PIC::Functions::$_"), @rolenames);
with @roles;

sub list_features {
    my @arr = grep {!/CodeGen|Oper|Chip|ISR/} @rolenames;
    return wantarray ? @arr : [@arr];
}

1;
__END__

=encoding utf8

=head1 NAME

VIC::PIC::P16F687

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
