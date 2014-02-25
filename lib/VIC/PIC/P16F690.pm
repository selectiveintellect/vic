package VIC::PIC::P16F690;
use strict;
use warnings;
use Carp;
use POSIX ();
use Pegex::Base; # use this instead of Mo

our $VERSION = '0.03';
$VERSION = eval $VERSION;

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

has config => <<"...";
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

sub digital_output {
    my ($self, $outp) = @_;
    return unless defined $outp;
    my $code;
    if (exists $self->ports->{$outp}) {
        my $port = $self->ports->{$outp};
        $code = << "...";
\tbanksel TRIS$port
\tclrf TRIS$port
\tbanksel $outp
\tclrf $outp
...
    } elsif (exists $self->pins->{$outp}) {
        my ($port, $portbit) = @{$self->pins->{$outp}};
        if (defined $port and defined $portbit) {
            $code = << "...";
\tbanksel TRIS$port
\tbcf TRIS$port, TRIS$port$portbit
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
        return $self->assign_literal("PORT$port", $val) if ($val =~ /^\d+$/);
        return $self->assign_variable("PORT$port", uc $val);
    } elsif (exists $self->pins->{$outp}) {
        my ($port, $portbit) = @{$self->pins->{$outp}};
        if ($val =~ /^\d+$/) {
            return "\tbcf PORT$port, $portbit\n" if "$val" eq '0';
            return "\tbsf PORT$port, $portbit\n" if "$val" eq '1';
            carp "$val cannot be applied to a pin $outp";
        }
        return $self->assign_variable("PORT$port", uc $val);
    } elsif ($self->validate($outp)) {
        my $code = "\tbanksel $outp\n";
        $code .= ($val =~ /^\d+$/) ? $self->assign_literal($outp, $val) :
                                    $self->assign_variable($outp, uc $val);
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
        $code = << "...";
\tbanksel TRIS$port
\tmovlw 0xFF
\tmovwf TRIS$port
\tbanksel ANSEL
\tclrf ANSEL
\tclrf ANSELH
\tbanksel PORT$port
...
    } elsif (exists $self->pins->{$inp}) {
        my ($port, $portbit, $pin) = @{$self->pins->{$inp}};
        if (defined $port and defined $portbit and defined $pin) {
            my $flags = 0;
            my $flagsH = 0;
            if (exists $self->analog_pins->{$pin}) {
                my $pinname = $self->analog_pins->{$pin};
                my ($apin, $abit) = @{$self->analog_pins->{$pinname}};
                $flags ^= 1 << $abit if $abit < 8;
                $flagsH ^= 1 << ($abit - 8) if $abit >= 8;
            }
            $flags = sprintf "0x%02X", $flags;
            $flagsH = sprintf "0x%02X", $flagsH;
            $code = << "...";
\tbanksel TRIS$port
\tbsf TRIS$port, TRIS$port$portbit
\tbanksel ANSEL
\tmovlw $flags
\tmovwf ANSEL
\tmovlw $flagsH
\tmovwf ANSELH
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
    if (exists $self->ports->{$inp}) {
        my $port = $self->ports->{$inp};
        $code = << "...";
\tbanksel TRIS$port
\tclrf TRIS$port
\tbanksel ANSEL
\tmovlw 0xFF
\tmovwf ANSEL
\tmovwf ANSELH
\tbanksel PORT$port
...
    } elsif (exists $self->pins->{$inp}) {
        my ($port, $portbit, $pin) = @{$self->pins->{$inp}};
        if (defined $port and defined $portbit and defined $pin) {
            my $flags = 0xFF;
            my $flagsH = 0xFF;
            if (exists $self->analog_pins->{$pin}) {
                my $pinname = $self->analog_pins->{$pin};
                my ($apin, $abit) = @{$self->analog_pins->{$pinname}};
                $flags ^= 1 << $abit if $abit < 8;
                $flagsH ^= 1 << ($abit - 8) if $abit >= 8;
            }
            $flags = sprintf "0x%02X", $flags;
            $flagsH = sprintf "0x%02X", $flagsH;
            $code = << "...";
\tbanksel TRIS$port
\tbcf TRIS$port, TRIS$port$portbit
\tbanksel ANSEL
\tmovlw $flags
\tmovwf ANSEL
\tmovlw $flagsH
\tmovwf ANSELH
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

sub m_delay_wus {
    return <<'...';
m_delay_wus macro
    local _delayw_usecs_loop_0
    movwf   DELAY_VAR
_delayw_usecs_loop_0:
    decfsz  DELAY_VAR, F
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

sub m_delay_wms {
    return <<'...';
m_delay_wms macro
    local _delayw_msecs_loop_0, _delayw_msecs_loop_1
    movwf   DELAY_VAR + 1
_delayw_msecs_loop_1:
    clrf   DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delayw_msecs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delayw_msecs_loop_0
    decfsz  DELAY_VAR + 1, F
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

sub m_delay_ws {
    return <<'...';
m_delay_ws macro
    local _delayw_secs_loop_0, _delayw_secs_loop_1, _delayw_secs_loop_2
    movwf   DELAY_VAR + 2
_delayw_secs_loop_2:
    clrf    DELAY_VAR + 1   ;; set to 0 which gets decremented to 0xFF
_delayw_secs_loop_1:
    clrf    DELAY_VAR   ;; set to 0 which gets decremented to 0xFF
_delayw_secs_loop_0:
    decfsz  DELAY_VAR, F
    goto    _delayw_secs_loop_0
    decfsz  DELAY_VAR + 1, F
    goto    _delayw_secs_loop_1
    decfsz  DELAY_VAR + 2, F
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
\tmovf  $var2, W
\tmovwf $var1
...
}

sub assign_expression {
    my $self = shift;
    my $var1 = shift;
    return unless scalar @_;
    my @code = ("\tclrw\n");
    foreach my $expr (@_) {
        if ($expr =~ /^OP::(NOT|COMP)::(\w+)$/) {
            # this is a unary operation
            my $op = $1;
            my $var2 = uc $2;
            my $comp_code = << "...";
;; generate code for ~$var2
\tcomf $var2, W
...
            my $not_code = << "...";
;; generate code for !$var2
\tcomf $var2, W
\tbtfsc STATUS, Z
\tmovlw 1
...
            push @code, $comp_code if $op eq 'COMP';
            push @code, $not_code if $op eq 'NOT';
        } else {
            carp "Unable to handle $expr\n";
        }
    }
    push @code, "\tmovwf $var1\n";
    return join("\n", @code);
}

## FIXME: handle carry bit
sub selfadd_literal {
    my ($self, $var, $val) = @_;
    return "\n" if "$val" eq '0';
    return << "...";
\t;;moves $val to W
\tmovlw D'$val'
\taddwf $var, F
...
}

## FIXME: handle carry bit
sub selfadd_variable {
    my ($self, $var, $var2) = @_;
    return << "...";
\t;;moves $var2 to W
\tmovf $var2, W
\taddwf $var, F
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

sub check_eq {
    my ($self, $lhs, $rhs, $predicate, $ccount) = @_;
    my $pred = '';
    my $end_label = "_end_conditional_$ccount";
    my ($false_label, $true_label);
    if (ref $predicate eq 'ARRAY') {
        foreach my $p (@$predicate) {
            $false_label = $1 if $p =~ /LABEL::(\w+)::False/;
            $true_label = $1 if $p =~ /LABEL::(\w+)::True/;
            last if (defined $false_label and defined $true_label);
        }
        if (defined $false_label) {
            $pred .= "\tgoto $false_label\n";
        } else {
            $pred .= "\tgoto $end_label\n";
        }
        if (defined $true_label) {
            $pred .= "\tgoto $true_label\n";
        } else {
            $pred .= "\tgoto $end_label\n";
        }
    } else {
        carp "Predicate has to be an array";
        return;
    }
    $pred .= "$end_label:\n";
    if ($lhs =~ /OP::/ || $rhs =~ /OP::/) {

    } else {
        if ($lhs !~ /^\d+$/ and $rhs !~ /^\d+$/) {
            # lhs and rhs are variables
            $rhs = uc $rhs;
            $lhs = uc $lhs;
            return << "...";
\tbcf STATUS, C
\tmovf $rhs, W
\txorwf $lhs, W
\tbtfss STATUS, Z ;; they are equal
$pred
...
        } elsif ($rhs !~ /^\d+$/ and $lhs =~ /^\d+$/) {
            # rhs is variable and lhs is a literal
            $rhs = uc $rhs;
            return << "...";
\tmovf $rhs, W
\txorlw $lhs
\tbtfss STATUS, Z ;; $rhs == $lhs ?
$pred
...
        } elsif ($rhs =~ /^\d+$/ and $lhs !~ /^\d+$/) {
            # rhs is a literal and lhs is a variable
            $lhs = uc $lhs;
            return << "...";
\tmovf $lhs, W
\txorlw $rhs
\tbtfss STATUS, Z ;; $lhs == $rhs ?
$pred
...
        } else {
            # both rhs and lhs are literals
            if ($lhs == $rhs) {
                return << "...";
\tgoto $true_label\n
$end_label:
...
            } else {
                return << "...";
\tgoto $false_label\n
$end_label:
...
            }
        }
    }
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
    my ($self, $inp, $action) = @_;
    my ($end_label, $action_label);
    if ($action =~ /LABEL::(\w+)::\w+::\w+::\w+::(\w+)/) {
        $action_label = $1;
        $end_label = $2;
    }
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
    my $code = <<"...";
\t;;; generate code for debounce $port<$portbit>
$deb_code
\t;; has debounce state changed to down (bit 0 is 0)
\t;; if yes go to debounce-state-down
\tbtfsc   DEBOUNCESTATE, 0
\tgoto    _debounce_state_up
_debounce_state_down:
\tclrw
\tbtfss   PORT$port, $portbit
\t;; increment and move into counter
\tincf    DEBOUNCECOUNTER, 0
\tmovwf   DEBOUNCECOUNTER
\tgoto    _debounce_state_check

_debounce_state_up:
\tclrw
\tbtfsc   PORT$port, $portbit
\tincf    DEBOUNCECOUNTER, 0
\tmovwf   DEBOUNCECOUNTER
\tgoto    _debounce_state_check

_debounce_state_check:
\tmovf    DEBOUNCECOUNTER, W
\txorlw   $debounce_count
\t;; is counter == $debounce_count ?
\tbtfss   STATUS, Z
\tgoto    $end_label
\t;; after $debounce_count straight, flip direction
\tcomf    DEBOUNCESTATE, 1
\tclrf    DEBOUNCECOUNTER
\t;; was it a key-down
\tbtfss   DEBOUNCESTATE, 0
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
    return << "...";
cblock 0x70 ;; unbanked RAM
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
    my ($self, $tmr, $scale, $isr) = @_;
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
    $code .= "\n$isr_code\n" if $isr;
    $code .= "\n$end_code\n";
    my $funcs = {};
    my $macros = {};
    if ($isr) {
        my ($end_label, $action_label);
        if ($isr =~ /LABEL::(\w+)::\w+::\w+::\w+::(\w+)/) {
            $action_label = $1;
            $end_label = $2;
        }
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
    my ($self, $action) = @_;
    my ($end_label, $action_label);
    if ($action =~ /LABEL::(\w+)::\w+::\w+::\w+::(\w+)/) {
        $action_label = $1;
        $end_label = $2;
    }
    return unless $action_label;
    return unless $end_label;
    return << "...";
\tbtfss INTCON, T0IF
\tgoto $end_label
\tbcf INTCON, T0IF
\tgoto $action_label
$end_label:
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
