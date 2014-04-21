package VIC::PIC::P16F690;
use strict;
use warnings;
use bigint;
use Carp;
use POSIX ();
use Pegex::Base; # use this instead of Mo

our $VERSION = '0.06';
$VERSION = eval $VERSION;

has type => 'p16f690';

has include => 'p16f690.inc';

has org => 0;

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

sub update_code_config {
    my ($self, $grp, $key, $val) = @_;
    return unless defined $grp;
    $self->code_config->{$grp} = {} unless exists $self->code_config->{$grp};
    my $grpref = $self->code_config->{$grp};
    if ($key eq 'bits') {
        $val = 8 unless defined $val;
        $val = 8 if $val <= 8;
        $val = 16 if ($val > 8 and $val <= 16);
        $val = 32 if ($val > 16 and $val <= 32);
        carp "$val-bits is not supported. Maximum supported size is 64-bit"
            if $val > 64;
        $val = 64 if $val > 32;
    }
    $val = 1 unless defined $val;
    if (ref $grpref eq 'HASH') {
        $grpref->{$key} = $val;
    } else {
        $self->code_config->{$grp} = { $key => $val };
    }
    1;
}

sub address_bits {
    my ($self, $varname) = @_;
    my $bits = $self->code_config->{variable}->{bits};
    return $bits unless $varname;
    $bits = $self->code_config->{lc $varname}->{bits} || $bits;
    return $bits;
}

sub validate {
    my ($self, $var) = @_;
    return undef unless defined $var;
    return 0 if $var =~ /^\d+$/;
    return 1 if exists $self->pins->{$var};
    return 1 if exists $self->ports->{$var};
    return 1 if exists $self->analog_pins->{$var};
    return 1 if exists $self->register_banks->{$var};
    return 1 if exists $self->power_pins->{$var};
    return 1 if exists $self->comparator_pins->{$var};
    return 1 if exists $self->interrupt_pins->{$var};
    return 1 if exists $self->timer_pins->{$var};
    return 1 if exists $self->spi_pins->{$var};
    return 1 if exists $self->usart_pins->{$var};
    return 1 if exists $self->clock_pins->{$var};
    return 1 if exists $self->selector_pins->{$var};
    return 1 if exists $self->oscillator_pins->{$var};
    return 1 if exists $self->icsp_pins->{$var};
    return 1 if exists $self->i2c_pins->{$var};
    return 1 if exists $self->pwm_pins->{$var};
    return 0;
}

sub validate_operator {
    my ($self, $op) = @_;
    my $vop = "op_$op" if $op =~ /^
            LE | GE | GT | LT | EQ | NE |
            ADD | SUB | MUL | DIV | MOD |
            BXOR | BOR | BAND | AND | OR | SHL | SHR |
            ASSIGN | INC | DEC | NOT | COMP
        /x;
    return $vop;
}

sub validate_modifier {
    my ($self, $mod, $suffix) = @_;
    my $vmod = "op_$mod" if $mod =~ /^
            SQRT | HIGH | LOW
        /x;
    return $vmod;
}

sub digital_output {
    my ($self, $outp) = @_;
    return unless defined $outp;
    my $code;
    if (exists $self->ports->{$outp}) {
        my $port = $self->ports->{$outp};
        my $flags = 0xFF;
        my $flagsH = 0xFF;
        for (0 .. 7) {
            my $pin = 'R' . $port . $_;
            next unless exists $self->pins->{$pin};
            my ($p1, $p2, $pin_no) = @{$self->pins->{$pin}};
            my $apinname = $self->analog_pins->{$pin_no} if defined $pin_no;
            if (defined $apinname) {
                my ($apin, $abit) = @{$self->analog_pins->{$apinname}};
                $flags ^= 1 << $abit if $abit < 8;
                $flagsH ^= 1 << ($abit - 8) if $abit >= 8;
            }
        }
        my $an_code = '';
        if ($flags != 0) {
            $flags = sprintf "0x%02X", $flags;
            $an_code .= "\tbanksel ANSEL\n";
            $an_code .= "\tmovlw $flags\n";
            $an_code .= "\tandwf ANSEL, F\n";
        }
        if ($flagsH != 0) {
            $flagsH = sprintf "0x%02X", $flagsH;
            $an_code .= "\tbanksel ANSELH\n";
            $an_code .= "\tmovlw $flagsH\n";
            $an_code .= "\tandwf ANSELH, F\n";
        }
        $code = << "...";
\tbanksel TRIS$port
\tclrf TRIS$port
$an_code
\tbanksel $outp
\tclrf $outp
...
    } elsif (exists $self->pins->{$outp}) {
        my ($port, $portbit, $pin_no) = @{$self->pins->{$outp}};
        my $an_code = '';
        if (defined $port and defined $portbit) {
            my $apinname = $self->analog_pins->{$pin_no} if defined $pin_no;
            if (defined $apinname) {
                my ($apin, $abit) = @{$self->analog_pins->{$apinname}};
                my $ansel = ($abit >= 8) ? 'ANSELH' : 'ANSEL';
                $an_code = "\tbanksel $ansel\n\tbcf $ansel, ANS$abit";
            }
            $code = << "...";
\tbanksel TRIS$port
\tbcf TRIS$port, TRIS$port$portbit
$an_code
\tbanksel PORT$port
\tbcf PORT$port, $portbit
...
        }
    } else {
        carp "Cannot find $outp in the list of ports or pins";
    }
    return $code;
}

sub write {
    my ($self, $outp, $val) = @_;
    return unless defined $outp;
    if (exists $self->ports->{$outp}) {
        my $port = $self->ports->{$outp};
        unless (defined $val) {
            return << "...";
\tclrf PORT$port
\tcomf PORT$port, 1
...
        }
        return $self->op_ASSIGN("PORT$port", $val);
    } elsif (exists $self->pins->{$outp}) {
        my ($port, $portbit) = @{$self->pins->{$outp}};
        if ($val =~ /^\d+$/) {
            return "\tbcf PORT$port, $portbit\n" if "$val" eq '0';
            return "\tbsf PORT$port, $portbit\n" if "$val" eq '1';
            carp "$val cannot be applied to a pin $outp";
        }
        return $self->op_ASSIGN("PORT$port", $val);
    } elsif ($self->validate($outp)) {
        my $code = "\tbanksel $outp\n";
        $code .= $self->op_ASSIGN($outp, $val);
        return $code;
    } else {
        carp "Cannot find $outp in the list of ports or pins";
    }
}

sub analog_input {
    my ($self, $inp) = @_;
    return unless defined $inp;
    my $code;
    if (exists $self->ports->{$inp}) {
        my $port = $self->ports->{$inp};
        my $flags = 0;
        my $flagsH = 0;
        for (0 .. 7) {
            my $pin = 'R' . $port . $_;
            next unless exists $self->pins->{$pin};
            my ($p1, $p2, $pin_no) = @{$self->pins->{$pin}};
            my $apinname = $self->analog_pins->{$pin_no} if defined $pin_no;
            if (defined $apinname) {
                my ($apin, $abit) = @{$self->analog_pins->{$apinname}};
                $flags ^= 1 << $abit if $abit < 8;
                $flagsH ^= 1 << ($abit - 8) if $abit >= 8;
            }
        }
        my $an_code = '';
        if ($flags != 0) {
            $flags = sprintf "0x%02X", $flags;
            $an_code .= "\tbanksel ANSEL\n";
            $an_code .= "\tmovlw $flags\n";
            $an_code .= "\tiorwf ANSEL, F\n";
        }
        if ($flagsH != 0) {
            $flagsH = sprintf "0x%02X", $flagsH;
            $an_code .= "\tbanksel ANSELH\n";
            $an_code .= "\tmovlw $flagsH\n";
            $an_code .= "\tiorwf ANSELH, F\n";
        }
        $code = << "...";
\tbanksel TRIS$port
\tmovlw 0xFF
\tmovwf TRIS$port
$an_code
\tbanksel PORT$port
...
    } elsif (exists $self->pins->{$inp}) {
        my ($port, $portbit, $pin) = @{$self->pins->{$inp}};
        if (defined $port and defined $portbit and defined $pin) {
            my $an_code = '';
            if (exists $self->analog_pins->{$pin}) {
                my $pinname = $self->analog_pins->{$pin};
                my ($apin, $abit) = @{$self->analog_pins->{$pinname}};
                my $ansel = ($abit >= 8) ? 'ANSELH' : 'ANSEL';
                $an_code = "\tbanksel $ansel\n\tbsf $ansel, ANS$abit";
            }
            $code = << "...";
\tbanksel TRIS$port
\tbsf TRIS$port, TRIS$port$portbit
$an_code
\tbanksel PORT$port
...
        }
    } else {
        carp "Cannot find $inp the list of ports or pins";
    }
    return $code;
}
sub digital_input {
    my ($self, $inp) = @_;
    return unless defined $inp;
    my $code;
    my $an_code = '';
    if (exists $self->ports->{$inp}) {
        my $port = $self->ports->{$inp};
        my $flags = 0xFF;
        my $flagsH = 0xFF;
        for (0 .. 7) {
            my $pin = 'R' . $port . $_;
            next unless exists $self->pins->{$pin};
            my ($p1, $p2, $pin_no) = @{$self->pins->{$pin}};
            my $apinname = $self->analog_pins->{$pin_no} if defined $pin_no;
            if (defined $apinname) {
                my ($apin, $abit) = @{$self->analog_pins->{$apinname}};
                $flags ^= 1 << $abit if $abit < 8;
                $flagsH ^= 1 << ($abit - 8) if $abit >= 8;
            }
        }
        if ($flags != 0) {
            $flags = sprintf "0x%02X", $flags;
            $an_code .= "\tbanksel ANSEL\n";
            $an_code .= "\tmovlw $flags\n";
            $an_code .= "\tandwf ANSEL, F\n";
        }
        if ($flagsH != 0) {
            $flagsH = sprintf "0x%02X", $flagsH;
            $an_code .= "\tbanksel ANSELH\n";
            $an_code .= "\tmovlw $flagsH\n";
            $an_code .= "\tandwf ANSELH, F\n";
        }
        $code = << "...";
\tbanksel TRIS$port
\tclrf TRIS$port
$an_code
\tbanksel PORT$port
...
    } elsif (exists $self->pins->{$inp}) {
        my ($port, $portbit, $pin) = @{$self->pins->{$inp}};
        if (defined $port and defined $portbit and defined $pin) {
            my $apinname = $self->analog_pins->{$pin};
            if (defined $apinname) {
                my ($apin, $abit) = @{$self->analog_pins->{$apinname}};
                my $ansel = ($abit >= 8) ? 'ANSELH' : 'ANSEL';
                $an_code = "\tbanksel $ansel\n\tbcf $ansel, ANS$abit";
            }
            $code = << "...";
\tbanksel TRIS$port
\tbcf TRIS$port, TRIS$port$portbit
$an_code
\tbanksel PORT$port
...
        }
    } else {
        carp "Cannot find $inp the list of ports or pins";
    }
    return $code;
}

sub hang {
    my ($self, @args) = @_;
    return "\tgoto \$";
}

sub m_delay_var {
    return <<'...';
;;;;;; DELAY FUNCTIONS ;;;;;;;

VIC_VAR_DELAY_UDATA udata
VIC_VAR_DELAY   res 3

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
    movwf   VIC_VAR_DELAY
_delay_usecs_loop_0:
    decfsz  VIC_VAR_DELAY, F
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

sub m_delay_wus {
    return <<'...';
m_delay_wus macro
    local _delayw_usecs_loop_0
    movwf   VIC_VAR_DELAY
_delayw_usecs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delayw_usecs_loop_0
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
    movwf   VIC_VAR_DELAY + 1
_delay_msecs_loop_1:
    clrf   VIC_VAR_DELAY   ;; set to 0 which gets decremented to 0xFF
_delay_msecs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delay_msecs_loop_0
    decfsz  VIC_VAR_DELAY + 1, F
    goto    _delay_msecs_loop_1
    endm
...
}

sub m_delay_wms {
    return <<'...';
m_delay_wms macro
    local _delayw_msecs_loop_0, _delayw_msecs_loop_1
    movwf   VIC_VAR_DELAY + 1
_delayw_msecs_loop_1:
    clrf   VIC_VAR_DELAY   ;; set to 0 which gets decremented to 0xFF
_delayw_msecs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delayw_msecs_loop_0
    decfsz  VIC_VAR_DELAY + 1, F
    goto    _delayw_msecs_loop_1
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
    movwf   VIC_VAR_DELAY + 2
_delay_secs_loop_2:
    clrf    VIC_VAR_DELAY + 1   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_1:
    clrf    VIC_VAR_DELAY   ;; set to 0 which gets decremented to 0xFF
_delay_secs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delay_secs_loop_0
    decfsz  VIC_VAR_DELAY + 1, F
    goto    _delay_secs_loop_1
    decfsz  VIC_VAR_DELAY + 2, F
    goto    _delay_secs_loop_2
    endm
...
}

sub m_delay_ws {
    return <<'...';
m_delay_ws macro
    local _delayw_secs_loop_0, _delayw_secs_loop_1, _delayw_secs_loop_2
    movwf   VIC_VAR_DELAY + 2
_delayw_secs_loop_2:
    clrf    VIC_VAR_DELAY + 1   ;; set to 0 which gets decremented to 0xFF
_delayw_secs_loop_1:
    clrf    VIC_VAR_DELAY   ;; set to 0 which gets decremented to 0xFF
_delayw_secs_loop_0:
    decfsz  VIC_VAR_DELAY, F
    goto    _delayw_secs_loop_0
    decfsz  VIC_VAR_DELAY + 1, F
    goto    _delayw_secs_loop_1
    decfsz  VIC_VAR_DELAY + 2, F
    goto    _delayw_secs_loop_2
    endm
...
}

sub delay_s {
    my ($self, $t) = @_;
    return $self->delay($t * 1e6) if $t =~ /^\d+$/;
    return $self->delay_w(s => uc($t));
}

sub delay_ms {
    my ($self, $t) = @_;
    return $self->delay($t * 1000) if $t =~ /^\d+$/;
    return $self->delay_w(ms => uc($t));
}

sub delay_us {
    my ($self, $t) = @_;
    return $self->delay($t) if $t =~ /^\d+$/;
    return $self->delay_w(us => uc($t));
}

sub delay_w {
    my ($self, $unit, $varname) = @_;
    my $funcs = {};
    my $macros = { m_delay_var => $self->m_delay_var };
    my $fn = "_delay_w$unit";
    my $mac = "m_delay_w$unit";
    my $code = << "...";
\tmovf $varname, W
\tcall $fn
...
    $funcs->{$fn} = << "....";
\t$mac
\treturn
....
    $macros->{$mac} = $self->$mac;
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub delay {
    my ($self, $t) = @_;
    return $self->delay_w(s => uc($t)) unless $t =~ /^\d+$/;
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

sub op_SHL {
    my ($self, $var, $bits, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    if ($var !~ $literal and $bits =~ $literal) {
        $var = uc $var;
        $code .= "\t;;;; perform $var << $bits\n";
        if ($bits == 1) {
            $code .= "\trlf $var, W\n";
        } elsif ($bits == 0) {
            $code .= "\tmovf $var, W\n";
        } else {
            carp "Not implemented. use the 'shl' instruction\n";
            return;
        }
    } elsif ($var =~ $literal and $bits =~ $literal) {
        my $res = $var << $bits;
        $code .= "\t;;;; perform $var << $bits = $res\n";
        $code .= sprintf "\tmovlw 0x%02X\n", $res;
    } else {
        carp "Unable to handle $var << $bits";
        return;
    }
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return $code;
}

sub op_SHR {
    my ($self, $var, $bits, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    if ($var !~ $literal and $bits =~ $literal) {
        $var = uc $var;
        $code .= "\t;;;; perform $var >> $bits\n";
        if ($bits == 1) {
            $code .= "\trrf $var, W\n";
        } elsif ($bits == 0) {
            $code .= "\tmovf $var, W\n";
        } else {
            carp "Not implemented. use the 'shr' instruction\n";
            return;
        }
    } elsif ($var =~ $literal and $bits =~ $literal) {
        my $res = $var >> $bits;
        $code .= "\t;;;; perform $var >> $bits = $res\n";
        $code .= sprintf "\tmovlw 0x%02X\n", $res;
    } else {
        carp "Unable to handle $var >> $bits";
        return;
    }
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return $code;
}

sub shl {
    my ($self, $var, $bits) = @_;
    $var = uc $var;
    my $code = '';
    for (1 .. $bits) {
        $code .= << "...";
\trlf $var, 1
...
    }
    $code .= << "...";
\tbcf STATUS, C
...
}

sub rol {
    my ($self, $var, $bits) = @_;
    $var = uc $var;
    my $code = <<"...";
\tbcf STATUS, C
...
    for (1 .. $bits) {
        $code .= << "...";
\trlf $var, 1
\tbtfsc STATUS, C
\tbsf $var, 0
...
    }
    return $code;
}

sub shr {
    my ($self, $var, $bits) = @_;
    $var = uc $var;
    my $code = '';
    for (1 .. $bits) {
        $code .= << "...";
\trrf $var, 1
...
    }
    $code .= << "...";
\tbcf STATUS, C
...
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

sub op_ASSIGN_literal {
    my ($self, $var, $val) = @_;
    my $bits = $self->address_bits($var);
    my $bytes = POSIX::ceil($bits / 8);
    my $nibbles = 2 * $bytes;
    $var = uc $var;
    my $code = sprintf "\t;; moves $val (0x%0${nibbles}X) to $var\n", $val;
    if ($val >= 2 ** $bits) {
        carp "Warning: Value $val doesn't fit in $bits-bits";
        $code .= "\t;; $val doesn't fit in $bits-bits. Using ";
        $val &= (2 ** $bits) - 1;
        $code .= sprintf "%d (0x%0${nibbles}X)\n", $val, $val;
    }
    if ($val == 0) {
        $code .= "\tclrf $var\n";
        for (2 .. $bytes) {
            $code .= sprintf "\tclrf $var + %d\n", ($_ - 1);
        }
    } else {
        my $valbyte = $val & ((2 ** 8) - 1);
        $code .= sprintf "\tmovlw 0x%02X\n\tmovwf $var\n", $valbyte if $valbyte > 0;
        $code .= "\tclrf $var\n" if $valbyte == 0;
        for (2 .. $bytes) {
            my $k = $_ * 8;
            my $i = $_ - 1;
            my $j = $i * 8;
            # get the right byte. 64-bit math requires bigint
            $valbyte = (($val & ((2 ** $k) - 1)) & (2 ** $k - 2 ** $j)) >> $j;
            $code .= sprintf "\tmovlw 0x%02X\n\tmovwf $var + $i\n", $valbyte if $valbyte > 0;
            $code .= "\tclrf $var + $i\n" if $valbyte == 0;
        }
    }
    return $code;
}

sub op_ASSIGN {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    return $self->op_ASSIGN_literal($var1, $var2) if $var2 =~ $literal;
    my $b1 = POSIX::ceil($self->address_bits($var1) / 8);
    my $b2 = POSIX::ceil($self->address_bits($var2) / 8);
    $var2 = uc $var2;
    $var1 = uc $var1;
    my $code = "\t;; moving $var2 to $var1\n";
    if ($b1 == $b2) {
        $code .= "\tmovf $var2, W\n\tmovwf $var1\n";
        for (2 .. $b1) {
            my $i = $_ - 1;
            $code .= "\tmovf $var2 + $i, W\n\tmovwf $var1 + $i\n";
        }
    } elsif ($b1 > $b2) {
        # we are moving a smaller var into a larger var
        $code .= "\t;; $var2 has a smaller size than $var1\n";
        $code .= "\tmovf $var2, W\n\tmovwf $var1\n";
        for (2 .. $b2) {
            my $i = $_ - 1;
            $code .= "\tmovf $var2 + $i, W\n\tmovwf $var1 + $i\n";
        }
        $code .= "\t;; we practice safe assignment here. zero out the rest\n";
        # we practice safe mathematics here. zero-out the rest of the place
        $b2++;
        for ($b2 .. $b1) {
            $code .= sprintf "\tclrf $var1 + %d\n", ($_ - 1);
        }
    } elsif ($b1 < $b2) {
        # we are moving a larger var into a smaller var
        $code .= "\t;; $var2 has a larger size than $var1. truncating..,\n";
        $code .= "\tmovf $var2, W\n\tmovwf $var1\n";
        for (2 .. $b1) {
            my $i = $_ - 1;
            $code .= "\tmovf $var2 + $i, W\n\tmovwf $var1 + $i\n";
        }
    } else {
        carp "Warning: should never reach here: $var1 is $b1 bytes and $var2 is $b2 bytes";
    }
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return $code;
}

sub op_ASSIGN_w {
    my ($self, $var) = @_;
    return unless $var;
    $var = uc $var;
    return "\tmovwf $var\n";
}

sub op_NOT {
    my $self = shift;
    my $var2 = shift;
    my $pred = '';
    if (@_) {
        my ($dummy, %extra) = @_;
        $pred .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    }
    $var2 = uc $var2;
    return << "...";
\t;;;; generate code for !$var2
\tcomf $var2, W
\tbtfsc STATUS, Z
\tmovlw 1
$pred
...
}

sub op_COMP {
    my $self = shift;
    my $var2 = shift;
    my $pred = '';
    if (@_) {
        my ($dummy, %extra) = @_;
        $pred .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    }
    $var2 = uc $var2;
    return << "...";
\t;;;; generate code for ~$var2
\tcomf $var2, W
$pred
...
}

sub op_ADD_ASSIGN_literal {
    my ($self, $var, $val, %extra) = @_;
    my $b1 = POSIX::ceil($self->address_bits($var) / 8);
    $var = uc $var;
    my $nibbles = 2 * $b1;
    my $code = sprintf "\t;; $var = $var + 0x%0${nibbles}X\n", $val;
    return $code if $val == 0;
    # we expect b1 == 1,2,4,8
    my $b2 = 1 if $val < 2 ** 8;
    $b2 = 2 if ($val < 2 ** 16 and $val >= 2 ** 8);
    $b2 = 4 if ($val < 2 ** 32 and $val >= 2 ** 16);
    $b2 = 8 if ($val < 2 ** 64 and $val >= 2 ** 32);
    if ($b1 > $b2) {
    } elsif ($b1 < $b2) {

    } else {
        # $b1 == $b2
        my $valbyte = $val & ((2 ** 8) - 1);
        $code .= sprintf "\t;; add 0x%02X to byte[0]\n", $valbyte;
        $code .= sprintf "\tmovlw 0x%02X\n\taddwf $var, F\n", $valbyte if $valbyte > 0;
        $code .= sprintf "\tbcf STATUS, C\n" if $valbyte == 0;
        for (2 .. $b1) {
            my $k = $_ * 8;
            my $i = $_ - 1;
            my $j = $i * 8;
            # get the right byte. 64-bit math requires bigint
            $valbyte = (($val & ((2 ** $k) - 1)) & (2 ** $k - 2 ** $j)) >> $j;
            $code .= sprintf "\t;; add 0x%02X to byte[$i]\n", $valbyte;
            $code .= "\tbtfsc STATUS, C\n\tincf $var + $i, F\n";
            $code .= sprintf "\tmovlw 0x%02X\n\taddwf $var + $i, F\n", $valbyte if $valbyte > 0;
        }
    }
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return $code;
}

## TODO: handle carry bit
sub op_ADD_ASSIGN {
    my ($self, $var, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    return $self->op_ADD_ASSIGN_literal($var, $var2, %extra) if $var2 =~ $literal;
    $var = uc $var;
    $var2 = uc $var2;
    my $code = '';
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return << "...";
\t;;moves $var2 to W
\tmovf $var2, W
\taddwf $var, F
$code
...
}

## TODO: handle carry bit
sub op_SUB_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_SUB($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_MUL_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_MUL($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_DIV_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_DIV($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_MOD_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_MOD($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_BXOR_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_BXOR($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_BAND_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_BAND($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_BOR_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_BOR($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_SHL_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_SHL($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_SHR_ASSIGN {
    my ($self, $var, $var2) = @_;
    my ($code, $funcs, $macros) = $self->op_SHR($var, $var2);
    $code .= $self->op_ASSIGN_w($var);
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub op_INC {
    my ($self, $var) = @_;
    # we expect b1 == 1,2,4,8
    my $b1 = POSIX::ceil($self->address_bits($var) / 8);
    my $code = "\t;; increments $var in place\n";
    $code .= "\t;; increment byte[0]\n\tincf $var, F\n";
    for (2 .. $b1) {
        my $j = $_ - 1;
        my $i = $_ - 2;
        $code .= << "...";
\t;; increment byte[$j] iff byte[$i] == 0
\tbtfsc STATUS, Z
\tincf $var + $j, F
...
    }
    return $code;
}

sub op_DEC {
    my ($self, $var) = @_;
    my $b1 = POSIX::ceil($self->address_bits($var) / 8);
    my $code = "\t;; decrements $var in place\n";
    $code .= "\tmovf $var, W\n" if $b1 > 1;
    for (2 .. $b1) {
        my $i = $_ - 1;
        my $j = $i - 1;
        $code .= << "...";
\t;; decrement byte[$i] iff byte[$j] == 0
\tbtfsc STATUS, Z
\tdecf $var + $i, F
...
    }
    $code .= "\t;; decrement byte[0]\n\tdecf $var, F\n";
    return $code;
}

sub op_ADD {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    #TODO: temporary only 8-bit math
    my ($b1, $b2);
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        $b1 = $self->address_bits($var1);
        $b2 = $self->address_bits($var2);
        # both are variables
        $code .= << "...";
\t;; add $var1 and $var2 without affecting either
\tmovf $var1, W
\taddwf $var2, W
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        $b2 = $self->address_bits($var2);
        # var1 is literal and var2 is variable
        # TODO: check for bits for var1
        $code .= << "...";
\t;; add $var1 and $var2 without affecting $var2
\tmovf  $var2, W
\taddlw $var1
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        # var2 is literal and var1 is variable
        $b1 = $self->address_bits($var1);
        # TODO: check for bits for var1
        $code .= << "...";
\t;; add $var2 and $var1 without affecting $var1
\tmovf $var1, W
\taddlw $var2
...
    } else {
        # both are literals
        # TODO: check for bits
        my $var3 = $var1 + $var2;
        $var3 = sprintf "0x%02X", $var3;
        $code .= << "...";
\t;; $var1 + $var2 = $var3
\tmovlw $var3
...
    }
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return $code;
}

sub op_SUB {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    #TODO: temporary only 8-bit math
    my ($b1, $b2);
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        $b1 = $self->address_bits($var1);
        $b2 = $self->address_bits($var2);
        # both are variables
        $code .= << "...";
\t;; perform $var1 - $var2 without affecting either
\tmovf $var2, W
\tsubwf $var1, W
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        $b2 = $self->address_bits($var2);
        # var1 is literal and var2 is variable
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 - $var2 without affecting $var2
\tmovf $var2, W
\tsublw $var1
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        # var2 is literal and var1 is variable
        $b1 = $self->address_bits($var1);
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 - $var2 without affecting $var1
\tmovlw $var2
\tsubwf $var1, W
...
    } else {
        # both are literals
        # TODO: check for bits
        my $var3 = $var1 - $var2;
        $var3 = sprintf "0x%02X", $var3;
        $code .= << "...";
\t;; $var1 - $var2 = $var3
\tmovlw $var3
...
    }
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return $code;
}

sub m_multiply_var {
    # TODO: do more than 8 bits
    return << "...";
;;;;;; VIC_VAR_MULTIPLY VARIABLES ;;;;;;;

VIC_VAR_MULTIPLY_UDATA udata
VIC_VAR_MULTIPLICAND res 2
VIC_VAR_MULTIPLIER res 2
VIC_VAR_PRODUCT res 2
...
}

sub m_multiply_macro {
    return << "...";
;;;;;; Taken from Microchip PIC examples.
;;;;;; multiply v1 and v2 using shifting. multiplication of 8-bit values is done
;;;;;; using 16-bit variables. v1 is a variable and v2 is a constant
m_multiply_internal macro
    local _m_multiply_loop_0, _m_multiply_skip
    clrf VIC_VAR_PRODUCT
    clrf VIC_VAR_PRODUCT + 1
_m_multiply_loop_0:
    rrf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, C
    goto _m_multiply_skip
    movf VIC_VAR_MULTIPLIER + 1, W
    addwf VIC_VAR_PRODUCT + 1, F
    movf VIC_VAR_MULTIPLIER, W
    addwf VIC_VAR_PRODUCT, F
    btfsc STATUS, C
    incf VIC_VAR_PRODUCT + 1, F
_m_multiply_skip:
    bcf STATUS, C
    rlf VIC_VAR_MULTIPLIER, F
    rlf VIC_VAR_MULTIPLIER + 1, F
    movf VIC_VAR_MULTIPLICAND, F
    btfss STATUS, Z
    goto _m_multiply_loop_0
    movf VIC_VAR_PRODUCT, W
    endm
;;;;;;; v1 is variable and v2 is literal
m_multiply_1 macro v1, v2
    movf v1, W
    movwf VIC_VAR_MULTIPLIER
    clrf VIC_VAR_MULTIPLIER + 1
    movlw v2
    movwf VIC_VAR_MULTIPLICAND
    clrf VIC_VAR_MULTIPLICAND + 1
    m_multiply_internal
    endm
;;;;;; multiply v1 and v2 using shifting. multiplication of 8-bit values is done
;;;;;; using 16-bit variables. v1 and v2 are variables
m_multiply_2 macro v1, v2
    movf v1, W
    movwf VIC_VAR_MULTIPLIER
    clrf VIC_VAR_MULTIPLIER + 1
    movf v2, W
    movwf VIC_VAR_MULTIPLICAND
    clrf VIC_VAR_MULTIPLICAND + 1
    m_multiply_internal
    endm
...
}

sub op_MUL {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    #TODO: temporary only 8-bit math
    my ($b1, $b2);
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        $b1 = $self->address_bits($var1);
        $b2 = $self->address_bits($var2);
        # both are variables
        $code .= << "...";
\t;; perform $var1 * $var2 without affecting either
\tm_multiply_2 $var1, $var2
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        $b2 = $self->address_bits($var2);
        # var1 is literal and var2 is variable
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 * $var2 without affecting $var2
\tm_multiply_1 $var2, $var1
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        # var2 is literal and var1 is variable
        $b1 = $self->address_bits($var1);
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 * $var2 without affecting $var1
\tm_multiply_1 $var1, $var2
...
    } else {
        # both are literals
        # TODO: check for bits
        my $var3 = $var1 * $var2;
        $var3 = sprintf "0x%02X", $var3;
        $code .= << "...";
\t;; $var1 * $var2 = $var3
\tmovlw $var3
...
    }
    my $macros = {
        m_multiply_var => $self->m_multiply_var,
        m_multiply_macro => $self->m_multiply_macro,
    };
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return wantarray ? ($code, {}, $macros) : $code;
}

sub m_divide_var {
    # TODO: do more than 8 bits
    return << "...";
;;;;;; VIC_VAR_DIVIDE VARIABLES ;;;;;;;

VIC_VAR_DIVIDE_UDATA udata
VIC_VAR_DIVISOR res 2
VIC_VAR_REMAINDER res 2
VIC_VAR_QUOTIENT res 2
VIC_VAR_BITSHIFT res 2
VIC_VAR_DIVTEMP res 1
...
}

sub m_divide_macro {
    return << "...";
;;;;;; Taken from Microchip PIC examples.
m_divide_internal macro
    local _m_divide_shiftuploop, _m_divide_loop, _m_divide_shift
    clrf VIC_VAR_QUOTIENT
    clrf VIC_VAR_QUOTIENT + 1
    clrf VIC_VAR_BITSHIFT + 1
    movlw 0x01
    movwf VIC_VAR_BITSHIFT
_m_divide_shiftuploop:
    bcf STATUS, C
    rlf VIC_VAR_DIVISOR, F
    rlf VIC_VAR_DIVISOR + 1, F
    bcf STATUS, C
    rlf VIC_VAR_BITSHIFT, F
    rlf VIC_VAR_BITSHIFT + 1, F
    btfss VIC_VAR_DIVISOR + 1, 7
    goto _m_divide_shiftuploop
_m_divide_loop:
    movf VIC_VAR_DIVISOR, W
    subwf VIC_VAR_REMAINDER, W
    movwf VIC_VAR_DIVTEMP
    movf VIC_VAR_DIVISOR + 1, W
    btfss STATUS, C
    addlw 0x01
    subwf VIC_VAR_REMAINDER + 1, W
    btfss STATUS, C
    goto _m_divide_shift
    movwf VIC_VAR_REMAINDER + 1
    movf VIC_VAR_DIVTEMP, W
    movwf VIC_VAR_REMAINDER
    movf VIC_VAR_BITSHIFT + 1, W
    addwf VIC_VAR_QUOTIENT + 1, F
    movf VIC_VAR_BITSHIFT, W
    addwf VIC_VAR_QUOTIENT, F
_m_divide_shift:
    bcf STATUS, C
    rrf VIC_VAR_DIVISOR + 1, F
    rrf VIC_VAR_DIVISOR, F
    bcf STATUS, C
    rrf VIC_VAR_BITSHIFT + 1, F
    rrf VIC_VAR_BITSHIFT, F
    btfss STATUS, C
    goto _m_divide_loop
    endm
;;;;;; v1 and v2 are variables
m_divide_2 macro v1, v2
    movf v1, W
    movwf VIC_VAR_REMAINDER
    clrf VIC_VAR_REMAINDER + 1
    movf v2, W
    movwf VIC_VAR_DIVISOR
    clrf VIC_VAR_DIVISOR + 1
    m_divide_internal
    movf VIC_VAR_QUOTIENT, W
    endm
;;;;;; v1 is literal and v2 is variable
m_divide_1a macro v1, v2
    movlw v1
    movwf VIC_VAR_REMAINDER
    clrf VIC_VAR_REMAINDER + 1
    movf v2, W
    movwf VIC_VAR_DIVISOR
    clrf VIC_VAR_DIVISOR + 1
    m_divide_internal
    movf VIC_VAR_QUOTIENT, W
    endm
;;;;;;; v2 is literal and v1 is variable
m_divide_1b macro v1, v2
    movf v1, W
    movwf VIC_VAR_REMAINDER
    clrf VIC_VAR_REMAINDER + 1
    movlw v2
    movwf VIC_VAR_DIVISOR
    clrf VIC_VAR_DIVISOR + 1
    m_divide_internal
    movf VIC_VAR_QUOTIENT, W
    endm
m_mod_2 macro v1, v2
    m_divide_2 v1, v2
    movf VIC_VAR_REMAINDER, W
    endm
;;;;;; v1 is literal and v2 is variable
m_mod_1a macro v1, v2
    m_divide_1a v1, v2
    movf VIC_VAR_REMAINDER, W
    endm
;;;;;;; v2 is literal and v1 is variable
m_mod_1b macro v1, v2
    m_divide_1b v1, v2
    movf VIC_VAR_REMAINDER, W
    endm
...
}

sub op_DIV {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    #TODO: temporary only 8-bit math
    my ($b1, $b2);
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        $b1 = $self->address_bits($var1);
        $b2 = $self->address_bits($var2);
        # both are variables
        $code .= << "...";
\t;; perform $var1 / $var2 without affecting either
\tm_divide_2 $var1, $var2
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        $b2 = $self->address_bits($var2);
        # var1 is literal and var2 is variable
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 / $var2 without affecting $var2
\tm_divide_1a $var1, $var2
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        # var2 is literal and var1 is variable
        $b1 = $self->address_bits($var1);
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 / $var2 without affecting $var1
\tm_divide_1b $var1, $var2
...
    } else {
        # both are literals
        # TODO: check for bits
        my $var3 = int($var1 / $var2);
        $var3 = sprintf "0x%02X", $var3;
        $code .= << "...";
\t;; $var1 / $var2 = $var3
\tmovlw $var3
...
    }
    my $macros = {
        m_divide_var => $self->m_divide_var,
        m_divide_macro => $self->m_divide_macro,
    };
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return wantarray ? ($code, {}, $macros) : $code;
}

sub op_MOD {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    #TODO: temporary only 8-bit math
    my ($b1, $b2);
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        $b1 = $self->address_bits($var1);
        $b2 = $self->address_bits($var2);
        # both are variables
        $code .= << "...";
\t;; perform $var1 / $var2 without affecting either
\tm_mod_2 $var1, $var2
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        $b2 = $self->address_bits($var2);
        # var1 is literal and var2 is variable
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 / $var2 without affecting $var2
\tm_mod_1a $var1, $var2
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        # var2 is literal and var1 is variable
        $b1 = $self->address_bits($var1);
        # TODO: check for bits for var1
        $code .= << "...";
\t;; perform $var1 / $var2 without affecting $var1
\tm_mod_1b $var1, $var2
...
    } else {
        # both are literals
        # TODO: check for bits
        my $var3 = int($var1 % $var2);
        $var3 = sprintf "0x%02X", $var3;
        $code .= << "...";
\t;; $var1 / $var2 = $var3
\tmovlw $var3
...
    }
    my $macros = {
        m_divide_var => $self->m_divide_var,
        m_divide_macro => $self->m_divide_macro,
    };
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return wantarray ? ($code, {}, $macros) : $code;
}

sub op_BXOR {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        return << "...";
\t;; perform $var1 ^ $var2 and move into W
\tmovf $var1, W
\txorwf $var2, W
$code
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        return << "...";
\t;; perform $var1 ^ $var2 and move into W
\tmovlw $var2
\txorwf $var1, W
$code
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        return << "...";
\t;; perform $var1 ^ $var2 and move into W
\tmovlw $var1
\txorwf $var2, W
$code
...
    } else {
        my $var3 = $var1 ^ $var2;
        $var3 = sprintf "0x%02X", $var3;
        return << "...";
\t;; $var3 = $var1 ^ $var2. move into W
\tmovlw $var3
$code
...
    }
}

sub op_BAND {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        return << "...";
\t;; perform $var1 & $var2 and move into W
\tmovf $var1, W
\tandwf $var2, W
$code
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        return << "...";
\t;; perform $var1 & $var2 and move into W
\tmovlw $var2
\tandwf $var1, W
$code
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        return << "...";
\t;; perform $var1 & $var2 and move into W
\tmovlw $var1
\tandwf $var2, W
$code
...
    } else {
        my $var3 = $var2 & $var1;
        $var3 = sprintf "0x%02X", $var3;
        return << "...";
\t;; $var3 = $var1 & $var2. move into W
\tmovlw $var3
$code
...
    }
}

sub op_BOR {
    my ($self, $var1, $var2, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    if ($var1 !~ $literal and $var2 !~ $literal) {
        $var1 = uc $var1;
        $var2 = uc $var2;
        return << "...";
\t;; perform $var1 | $var2 and move into W
\tmovf $var1, W
\tiorwf $var2, W
$code
...
    } elsif ($var1 !~ $literal and $var2 =~ $literal) {
        $var1 = uc $var1;
        $var2 = sprintf "0x%02X", $var2;
        return << "...";
\t;; perform $var1 | $var2 and move into W
\tmovlw $var2
\tiorwf $var1, W
$code
...
    } elsif ($var1 =~ $literal and $var2 !~ $literal) {
        $var2 = uc $var2;
        $var1 = sprintf "0x%02X", $var1;
        return << "...";
\t;; perform $var1 | $var2 and move into W
\tmovlw $var1
\tiorwf $var2, W
$code
...
    } else {
        my $var3 = $var1 | $var2;
        $var3 = sprintf "0x%02X", $var3;
        return << "...";
\t;; $var3 = $var1 | $var2. move into W
\tmovlw $var3
$code
...
    }
}

sub get_predicate {
    my ($self, $comment, %extra) = @_;
    my $pred = '';
    ## predicate can be either a result or a jump block
    unless (defined $extra{RESULT}) {
        my $flabel = $extra{SWAP} ? $extra{TRUE} : $extra{FALSE};
        my $tlabel = $extra{SWAP} ? $extra{FALSE} : $extra{TRUE};
        my $elabel = $extra{END};
        $pred .= << "..."
\tbtfss STATUS, Z ;; $comment ?
\tgoto $flabel
\tgoto $tlabel
$elabel:
...
    } else {
        my $flabel = $extra{SWAP} ? "$extra{END}_t_$extra{COUNTER}" :
                        "$extra{END}_f_$extra{COUNTER}";
        my $tlabel = $extra{SWAP} ? "$extra{END}_f_$extra{COUNTER}" :
                        "$extra{END}_t_$extra{COUNTER}";
        my $elabel = "$extra{END}_e_$extra{COUNTER}";
        $pred .=  << "...";
\tbtfss STATUS, Z ;; $comment ?
\tgoto $flabel
\tgoto $tlabel
$flabel:
\tclrw
\tgoto $elabel
$tlabel:
\tmovlw 0x01
$elabel:
...
        $pred .= $self->op_ASSIGN_w($extra{RESULT});
    }
    return $pred;
}

sub get_predicate_literals {
    my ($self, $comment, $res, %extra) = @_;
    if (defined $extra{RESULT}) {
        my $tcode = 'movlw 0x01';
        my $fcode = 'clrw';
        my $code;
        if ($res) {
            $code = $extra{SWAP} ? $fcode : $tcode;
        } else {
            $code = $extra{SWAP} ? $tcode : $fcode;
        }
        my $ecode = $self->op_ASSIGN_w($extra{RESULT});
        return "\t$code ;;$comment\n$ecode\n";
    } else {
        my $label;
        if ($res) {
            $label = $extra{SWAP} ? $extra{FALSE} : $extra{TRUE};
        } else {
            $label = $extra{SWAP} ? $extra{TRUE} : $extra{FALSE};
        }
        return "\tgoto $label ;; $comment\n$extra{END}:\n";
    }
}

sub op_EQ {
    my ($self, $lhs, $rhs, %extra) = @_;
    my $comment = $extra{SWAP} ? "$lhs != $rhs" : "$lhs == $rhs";
    my $pred = $self->get_predicate($comment, %extra);
    my $literal = qr/^\d+$/;
    if ($lhs !~ $literal and $rhs !~ $literal) {
        # lhs and rhs are variables
        $rhs = uc $rhs;
        $lhs = uc $lhs;
        return << "...";
\tbcf STATUS, Z
\tmovf $rhs, W
\txorwf $lhs, W
$pred
...
    } elsif ($rhs !~ $literal and $lhs =~ $literal) {
        # rhs is variable and lhs is a literal
        $rhs = uc $rhs;
        $lhs = sprintf "0x%02X", $lhs;
        return << "...";
\tbcf STATUS, Z
\tmovf $rhs, W
\txorlw $lhs
$pred
...
    } elsif ($rhs =~ $literal and $lhs !~ $literal) {
        # rhs is a literal and lhs is a variable
        $lhs = uc $lhs;
        $rhs = sprintf "0x%02X", $rhs;
        return << "...";
\tbcf STATUS, Z
\tmovf $lhs, W
\txorlw $rhs
$pred
...
    } else {
        # both rhs and lhs are literals
        my $res = $lhs == $rhs ? 1 : 0;
        return $self->get_predicate_literals("$lhs == $rhs => $res", $res, %extra);
    }
}

sub op_LT {
    my ($self, $lhs, $rhs, %extra) = @_;
    my $pred = $self->get_predicate("$lhs < $rhs", %extra);
    my $literal = qr/^\d+$/;
    if ($lhs !~ $literal and $rhs !~ $literal) {
        # lhs and rhs are variables
        $rhs = uc $rhs;
        $lhs = uc $lhs;
        return << "...";
\t;; perform check for $lhs < $rhs or $rhs > $lhs
\tbcf STATUS, C
\tmovf $rhs, W
\tsubwf $lhs, W
\tbtfsc STATUS, C ;; W($rhs) > F($lhs) => C = 0
$pred
...
    } elsif ($rhs !~ $literal and $lhs =~ $literal) {
        # rhs is variable and lhs is a literal
        $rhs = uc $rhs;
        $lhs = sprintf "0x%02X", $lhs;
        return << "...";
\t;; perform check for $lhs < $rhs or $rhs > $lhs
\tbcf STATUS, C
\tmovf $rhs, W
\tsublw $lhs
\tbtfsc STATUS, C ;; W($rhs) > k($lhs) => C = 0
$pred
...
    } elsif ($rhs =~ $literal and $lhs !~ $literal) {
        # rhs is a literal and lhs is a variable
        $lhs = uc $lhs;
        $rhs = sprintf "0x%02X", $rhs;
        return << "...";
\t;; perform check for $lhs < $rhs or $rhs > $lhs
\tbcf STATUS, C
\tmovlw $rhs
\tsubwf $lhs, W
\tbtfsc STATUS, C ;; W($rhs) > F($lhs) => C = 0
$pred
...
    } else {
        # both rhs and lhs are literals
        my $res = $lhs < $rhs ? 1 : 0;
        return $self->get_predicate_literals("$lhs < $rhs => $res", $res, %extra);
    }
}

sub op_GE {
    my ($self, $lhs, $rhs, %extra) = @_;
    my $pred = $self->get_predicate("$lhs >= $rhs", %extra);
    my $literal = qr/^\d+$/;
    if ($lhs !~ $literal and $rhs !~ $literal) {
        # lhs and rhs are variables
        $rhs = uc $rhs;
        $lhs = uc $lhs;
        return << "...";
\t;; perform check for $lhs >= $rhs or $rhs <= $lhs
\tbcf STATUS, C
\tmovf $rhs, W
\tsubwf $lhs, W
\tbtfss STATUS, C ;; W($rhs) <= F($lhs) => C = 1
$pred
...
    } elsif ($rhs !~ $literal and $lhs =~ $literal) {
        # rhs is variable and lhs is a literal
        $rhs = uc $rhs;
        $lhs = sprintf "0x%02X", $lhs;
        return << "...";
\t;; perform check for $lhs >= $rhs or $rhs <= $lhs
\tbcf STATUS, C
\tmovf $rhs, W
\tsublw $lhs
\tbtfss STATUS, C ;; W($rhs) <= k($lhs) => C = 1
$pred
...
    } elsif ($rhs =~ $literal and $lhs !~ $literal) {
        # rhs is a literal and lhs is a variable
        $lhs = uc $lhs;
        $rhs = sprintf "0x%02X", $rhs;
        return << "...";
\t;; perform check for $lhs >= $rhs or $rhs <= $lhs
\tbcf STATUS, C
\tmovlw $rhs
\tsubwf $lhs, W
\tbtfss STATUS, C ;; W($rhs) <= F($lhs) => C = 1
$pred
...
    } else {
        # both rhs and lhs are literals
        my $res = $lhs >= $rhs ? 1 : 0;
        return $self->get_predicate_literals("$lhs >= $rhs => $res", $res, %extra);
    }
}

sub op_NE {
    my ($self, $lhs, $rhs, %extra) = @_;
    return $self->op_EQ($lhs, $rhs, %extra, SWAP => 1);
}

sub op_LE {
    my ($self, $lhs, $rhs, %extra) = @_;
    # we swap the lhs/rhs stuff instead of using SWAP
    return $self->op_GE($rhs, $lhs, %extra);
}

sub op_GT {
    my ($self, $lhs, $rhs, %extra) = @_;
    # we swap the lhs/rhs stuff instead of using SWAP
    return $self->op_LT($rhs, $lhs, %extra);
}

sub op_AND {
    my ($self, $lhs, $rhs, %extra) = @_;
    my $pred = $self->get_predicate("$lhs && $rhs", %extra);
    my $literal = qr/^\d+$/;
    if ($lhs !~ $literal and $rhs !~ $literal) {
        # lhs and rhs are variables
        $rhs = uc $rhs;
        $lhs = uc $lhs;
        return << "...";
\t;; perform check for $lhs && $rhs
\tbcf STATUS, Z
\tmovf $lhs, W
\tbtfss STATUS, Z  ;; $lhs is false if it is set else true
\tmovf $rhs, W
\tbtfss STATUS, Z ;; $rhs is false if it is set else true
$pred
...
    } elsif ($rhs !~ $literal and $lhs =~ $literal) {
        # rhs is variable and lhs is a literal
        $rhs = uc $rhs;
        $lhs = sprintf "0x%02X", $lhs;
        return << "...";
\t;; perform check for $lhs && $rhs
\tbcf STATUS, Z
\tmovlw $lhs
\txorlw 0x00        ;; $lhs ^ 0 will set the Z bit
\tbtfss STATUS, Z  ;; $lhs is false if it is set else true
\tmovf $rhs, W
\tbtfss STATUS, Z ;; $rhs is false if it is set else true
$pred
...
    } elsif ($rhs =~ $literal and $lhs !~ $literal) {
        # rhs is a literal and lhs is a variable
        $lhs = uc $lhs;
        $rhs = sprintf "0x%02X", $rhs;
        return << "...";
\t;; perform check for $lhs && $rhs
\tbcf STATUS, Z
\tmovlw $rhs
\txorlw 0x00        ;; $rhs ^ 0 will set the Z bit
\tbtfss STATUS, Z  ;; $rhs is false if it is set else true
\tmovf $lhs, W
\tbtfss STATUS, Z ;; $lhs is false if it is set else true
$pred
...
    } else {
        # both rhs and lhs are literals
        my $res = ($lhs && $rhs) ? 1 : 0;
        return $self->get_predicate_literals("$lhs && $rhs => $res", $res, %extra);
    }
}

sub op_OR {
    my ($self, $lhs, $rhs, %extra) = @_;
    my $pred = $self->get_predicate("$lhs || $rhs", %extra);
    my $literal = qr/^\d+$/;
    if ($lhs !~ $literal and $rhs !~ $literal) {
        # lhs and rhs are variables
        $rhs = uc $rhs;
        $lhs = uc $lhs;
        return << "...";
\t;; perform check for $lhs || $rhs
\tbcf STATUS, Z
\tmovf $lhs, W
\tbtfsc STATUS, Z  ;; $lhs is false if it is set else true
\tmovf $rhs, W
\tbtfsc STATUS, Z ;; $rhs is false if it is set else true
$pred
...
    } elsif ($rhs !~ $literal and $lhs =~ $literal) {
        # rhs is variable and lhs is a literal
        $rhs = uc $rhs;
        $lhs = sprintf "0x%02X", $lhs;
        return << "...";
\t;; perform check for $lhs || $rhs
\tbcf STATUS, Z
\tmovlw $lhs
\txorlw 0x00        ;; $lhs ^ 0 will set the Z bit
\tbtfsc STATUS, Z  ;; $lhs is false if it is set else true
\tmovf $rhs, W
\tbtfsc STATUS, Z ;; $rhs is false if it is set else true
$pred
...
    } elsif ($rhs =~ $literal and $lhs !~ $literal) {
        # rhs is a literal and lhs is a variable
        $lhs = uc $lhs;
        $rhs = sprintf "0x%02X", $rhs;
        return << "...";
\t;; perform check for $lhs || $rhs
\tbcf STATUS, Z
\tmovlw $rhs
\txorlw 0x00        ;; $rhs ^ 0 will set the Z bit
\tbtfsc STATUS, Z  ;; $rhs is false if it is set else true
\tmovf $lhs, W
\tbtfsc STATUS, Z ;; $lhs is false if it is set else true
$pred
...
    } else {
        # both rhs and lhs are literals
        my $res = ($lhs || $rhs) ? 1 : 0;
        return $self->get_predicate_literals("$lhs || $rhs => $res", $res, %extra);
    }
}

sub m_sqrt_var {
    return << '...';
;;;;;; VIC_VAR_SQRT VARIABLES ;;;;;;
VIC_VAR_SQRT_UDATA udata
VIC_VAR_SQRT_VAL res 2
VIC_VAR_SQRT_RES res 2
VIC_VAR_SQRT_SUM res 2
VIC_VAR_SQRT_ODD res 2
VIC_VAR_SQRT_TMP res 2
...
}

sub m_sqrt_macro {
    return << '...';
;;;;;; Taken from Microchip PIC examples.
;;;;;; reverse of Finite Difference Squaring
m_sqrt_internal macro
    local _m_sqrt_loop, _m_sqrt_loop_break
    movlw 0x01
    movwf VIC_VAR_SQRT_ODD
    clrf VIC_VAR_SQRT_ODD + 1
    clrf VIC_VAR_SQRT_RES
    clrf VIC_VAR_SQRT_RES + 1
    clrf VIC_VAR_SQRT_SUM
    clrf VIC_VAR_SQRT_SUM + 1
    clrf VIC_VAR_SQRT_TMP
    clrf VIC_VAR_SQRT_TMP + 1
_m_sqrt_loop:
    movf VIC_VAR_SQRT_SUM + 1, W
    addwf VIC_VAR_SQRT_ODD + 1, W
    movwf VIC_VAR_SQRT_TMP + 1
    movf VIC_VAR_SQRT_SUM, W
    addwf VIC_VAR_SQRT_ODD, W
    movwf VIC_VAR_SQRT_TMP
    btfsc STATUS, C
    incf VIC_VAR_SQRT_TMP + 1, F
    movf VIC_VAR_SQRT_TMP, W
    subwf VIC_VAR_SQRT_VAL, W
    movf VIC_VAR_SQRT_TMP + 1, W
    btfss STATUS, C
    addlw 0x01
    subwf VIC_VAR_SQRT_VAL + 1, W
    btfss STATUS, C
    goto _m_sqrt_loop_break
    movf VIC_VAR_SQRT_TMP + 1, W
    movwf VIC_VAR_SQRT_SUM + 1
    movf VIC_VAR_SQRT_TMP, W
    movwf VIC_VAR_SQRT_SUM
    movlw 0x02
    addwf VIC_VAR_SQRT_ODD, F
    btfsc STATUS, C
    incf VIC_VAR_SQRT_ODD + 1, F
    incf VIC_VAR_SQRT_RES, F
    btfsc STATUS, Z
    incf VIC_VAR_SQRT_RES + 1, F
    goto _m_sqrt_loop
_m_sqrt_loop_break:
    endm
m_sqrt_8bit macro v1
    movf v1, W
    movwf VIC_VAR_SQRT_VAL
    clrf VIC_VAR_SQRT_VAL + 1
    m_sqrt_internal
    movf VIC_VAR_SQRT_RES, W
    endm
m_sqrt_16bit macro v1
    movf high v1, W
    movwf VIC_VAR_SQRT_VAL + 1
    movf low v1, W
    movwf VIC_VAR_SQRT_VAL
    m_sqrt_internal
    movf VIC_VAR_SQRT_RES, W
    endm
...
}

sub op_SQRT {
    my ($self, $var1, $dummy, %extra) = @_;
    my $literal = qr/^\d+$/;
    my $code = '';
    #TODO: temporary only 8-bit math
    if ($var1 !~ $literal) {
        $var1 = uc $var1;
        my $b1 = $self->address_bits($var1) || 8;
        # both are variables
        $code .= << "...";
\t;; perform sqrt($var1)
\tm_sqrt_${b1}bit $var1
...
    } elsif ($var1 =~ $literal) {
        my $svar = sqrt $var1;
        my $var2 = sprintf "0x%02X", int($svar);
        $code .= << "...";
\t;; sqrt($var1) = $svar -> $var2;
\tmovlw $var2
...
    } else {
        carp "Warning: $var1 cannot have a square root";
        return;
    }
    my $macros = {
        m_sqrt_var => $self->m_sqrt_var,
        m_sqrt_macro => $self->m_sqrt_macro,
    };
    $code .= $self->op_ASSIGN_w($extra{RESULT}) if $extra{RESULT};
    return wantarray ? ($code, {}, $macros) : $code;
}

sub m_debounce_var {
    return <<'...';
;;;;;; VIC_VAR_DEBOUNCE VARIABLES ;;;;;;;

VIC_VAR_DEBOUNCE_VAR_IDATA idata
;; initialize state to 1
VIC_VAR_DEBOUNCESTATE db 0x01
;; initialize counter to 0
VIC_VAR_DEBOUNCECOUNTER db 0x00

...
}

sub debounce {
    my ($self, $inp, %action) = @_;
    my $action_label = $action{ACTION};
    my $end_label = $action{END};
    return unless $action_label;
    return unless $end_label;
    my ($port, $portbit);
    if (exists $self->pins->{$inp}) {
        ($port, $portbit) = @{$self->pins->{$inp}};
    } elsif (exists $self->ports->{$inp}) {
        $port = $self->ports->{$inp};
        $portbit = 0;
        carp "Port $inp has been supplied. Assuming portbit to debounce is $portbit";
    } else {
        carp "Cannot find $inp in the list of ports or pins";
        return;
    }
    # incase the user does weird stuff override the count and delay
    my $debounce_count = $self->code_config->{debounce}->{count} || 1;
    my $debounce_delay = $self->code_config->{debounce}->{delay} || 1000;
    my ($deb_code, $funcs, $macros) = $self->delay($debounce_delay);
    $macros = {} unless defined $macros;
    $funcs = {} unless defined $funcs;
    $deb_code = 'nop' unless defined $deb_code;
    $macros->{m_debounce_var} = $self->m_debounce_var;
    $debounce_count = sprintf "0x%02X", $debounce_count;
    my $code = <<"...";
\t;;; generate code for debounce $port<$portbit>
$deb_code
\t;; has debounce state changed to down (bit 0 is 0)
\t;; if yes go to debounce-state-down
\tbtfsc   VIC_VAR_DEBOUNCESTATE, 0
\tgoto    _debounce_state_up
_debounce_state_down:
\tclrw
\tbtfss   PORT$port, $portbit
\t;; increment and move into counter
\tincf    VIC_VAR_DEBOUNCECOUNTER, 0
\tmovwf   VIC_VAR_DEBOUNCECOUNTER
\tgoto    _debounce_state_check

_debounce_state_up:
\tclrw
\tbtfsc   PORT$port, $portbit
\tincf    VIC_VAR_DEBOUNCECOUNTER, 0
\tmovwf   VIC_VAR_DEBOUNCECOUNTER
\tgoto    _debounce_state_check

_debounce_state_check:
\tmovf    VIC_VAR_DEBOUNCECOUNTER, W
\txorlw   $debounce_count
\t;; is counter == $debounce_count ?
\tbtfss   STATUS, Z
\tgoto    $end_label
\t;; after $debounce_count straight, flip direction
\tcomf    VIC_VAR_DEBOUNCESTATE, 1
\tclrf    VIC_VAR_DEBOUNCECOUNTER
\t;; was it a key-down
\tbtfss   VIC_VAR_DEBOUNCESTATE, 0
\tgoto    $end_label
\tgoto    $action_label
$end_label:\n
...
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub adc_enable {
    my $self = shift;
    if (@_) {
        my ($clock, $channel) = @_;
        my $scale = int(1e6 / $clock) if $clock > 0;
        $scale = 2 unless $clock;
        $scale = 2 if $scale < 2;
        my $adcs = $self->adcon1_scale->{$scale};
        $adcs = $self->adcon1_scale->{internal} if $self->code_config->{adc}->{internal};
        my $adcon1 = "0$adcs" . '0000';
        my $code = << "...";
\tbanksel ADCON1
\tmovlw B'$adcon1'
\tmovwf ADCON1
...
        if (defined $channel) {
            my $adfm = defined $self->code_config->{adc}->{right_justify} ?
            $self->code_config->{adc}->{right_justify} : 1;
            my $vcfg = $self->code_config->{adc}->{vref} || 0;
            my ($pin, $pbit, $chs) = @{$self->analog_pins->{$channel}};
            my $adcon0 = "$adfm$vcfg$chs" . '01';
            $code .= << "...";
\tbanksel ADCON0
\tmovlw B'$adcon0'
\tmovwf ADCON0
...
        }
        return $code;
    }
    # no arguments have been given
    return << "...";
\tbanksel ADCON0
\tbsf ADCON0, ADON
...
}

sub adc_disable {
    my $self = shift;
    return << "...";
\tbanksel ADCON0
\tbcf ADCON0, ADON
...
}

sub adc_read {
    my ($self, $varhigh, $varlow) = @_;
    $varhigh = uc $varhigh;
    $varlow = uc $varlow if defined $varlow;
    my $code = << "...";
\t;;;delay 5us
\tnop
\tnop
\tnop
\tnop
\tnop
\tbsf ADCON0, GO
\tbtfss ADCON0, GO
\tgoto \$ - 1
\tmovf ADRESH, W
\tmovwf $varhigh
...
    $code .= "\tmovf ADRESL, W\n\tmovwf $varlow\n" if defined $varlow;
    return $code;
}

sub isr_var {
    my $self = shift;
    my ($cb_start, $cb_end) = @{$self->banks->{common_bank}};
    $cb_start = 0x70 unless $cb_start;
    $cb_start = sprintf "0x%02X", $cb_start;
    return << "...";
cblock $cb_start ;; unbanked RAM that is common across all banks
ISR_STATUS
ISR_W
endc
...
}

sub isr_entry {
    my $self = shift;
    my $isr_addr = $self->isr_address;
    my $org_addr = $self->org;
    my $count = $isr_addr - $org_addr - 1;
    my $nops = '';
    for my $i (1 .. $count) {
        $nops .= "\tnop\n";
    }
    return << "...";
$nops
\torg $isr_addr
ISR:
_isr_entry:
\tmovwf ISR_W
\tmovf STATUS, W
\tmovwf ISR_STATUS
...
}

sub isr_exit {
    return << "...";
_isr_exit:
\tmovf ISR_STATUS, W
\tmovwf STATUS
\tswapf ISR_W, F
\tswapf ISR_W, W
\tretfie
...
}

sub timer_enable {
    my ($self, $tmr, $scale, %isr) = @_;
    unless (exists $self->timer_pins->{$tmr}) {
        carp "$tmr is not a timer.";
        return;
    }
    my $psx = $self->timer_prescaler->{$scale} || $self->timer_prescaler->{256};
    my $code = << "...";
;; timer prescaling
\tbanksel OPTION_REG
\tclrw
\tiorlw B'00000$psx'
\tmovwf OPTION_REG
...
    my $isr_code = << "...";
;; enable interrupt servicing
\tbanksel INTCON
\tclrf INTCON
\tbsf INTCON, GIE
\tbsf INTCON, T0IE
...
    my $end_code = << "...";
;; clear the timer
\tbanksel $tmr
\tclrf $tmr
...
    $code .= "\n$isr_code\n" if %isr;
    $code .= "\n$end_code\n";
    my $funcs = {};
    my $macros = {};
    if (%isr) {
        my $action_label = $isr{ISR};
        my $end_label = $isr{END};
        return unless $action_label;
        return unless $end_label;
        $funcs->{isr_timer} = << "..."
_isr_timer:
\tbtfss INTCON, T0IF
\tgoto $end_label
\tbcf   INTCON, T0IF
\tgoto $action_label
$end_label:
...
    }
    return wantarray ? ($code, $funcs, $macros) : $code;
}

sub timer_disable {
    my ($self, $tmr) = @_;
    unless (exists $self->timer_pins->{$tmr}) {
        carp "$tmr is not a timer.";
        return;
    }
    return << "...";
\tbanksel INTCON
\tbcf INTCON, T0IE ;; disable only the timer bit
\tbanksel OPTION_REG
\tmovlw B'00001000'
\tmovwf OPTION_REG
\tbanksel $tmr
\tclrf $tmr
...

}

sub timer {
    my ($self, %action) = @_;
    return unless exists $action{ACTION};
    return unless exists $action{END};
    return << "...";
\tbtfss INTCON, T0IF
\tgoto $action{END}
\tbcf INTCON, T0IF
\tgoto $action{ACTION}
$action{END}:
...
}

sub break { return 'BREAK'; }
sub continue { return 'CONTINUE'; }

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
