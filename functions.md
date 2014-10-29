# Function Reference

There are several in-built functions in VIC&trade; that perform common tasks
which can be abstracted out fairly between various PIC&reg; MCUs.

Implementing these common functions in C or assembly, are often a source of
error for the programmer. Moreover, every programmer might have to reinvent the
wheel by reimplementing these functions in various projects. Hence, we provide
some common functions that are useful to everyone, thus saving time.

The functions are organized in sections by relevance. As newer versions of
VIC&trade; are released in the future, more and more functions will continue to
be added. If there is a function that needs to be deprecated, VIC&trade; will be
very noisy about it and inform the programmer on how to fix their code.

## Pin I/O Functions

- `digital_output`

    Syntax:

        digital_output <PORT | PIN>;

    This function sets the given MCU port or pin name as a digital output. It
internally will generate code handling the appropriate registers for the MCU to
accomplish this task. A port for a PIC&reg; MCU allows all the pins to be
selected at once. An example of a port is `PORTA` and an example of a pin is
`RA0`.

    Examples:

        digital_output PORTA;
        digital_output RC0;

- `write`

    Syntax:

        write <PORT>, <constant | variable | PORT>;
        write <PIN>, <constant | variable | PIN>;

    This function _writes_ values to an MCU pin or a port register. The values
written to a pin can be a constant such as `0` or `1` or a variable with those
values or another pin. The values written to a port can be an 8-bit constant or
a variable with contents of its lower 8-bits or another port.

    When you write a pin to another pin or a port to another port, you are
really bit-banging the value. Sometimes it might make sense to just use a wire
between the pins if they are always mirroring each other but that might not be
your scenario. Hence, we provide such an option.

    Examples:

        write RC0, 1;
        write RA0, $flag; # $flag is a variable
        write PORTA, 0xFF;
        write PORTC, $display; # $display is a variable
        write RC0, RA0;
        write PORTA, PORTC;

- `analog_input`

- `digital_input`

- `debounce`

## Time Management Functions

- `delay`

- `delay_us`

- `delay_ms`

- `delay_s`

- `hang`

## Timer and Interrupt Functions

- `timer_enable`

- `timer_disable`

- `timer`

## Math Functions

- `rol`

- `ror`

- `sqrt`

## Analog/Digital Converter Functions

- `adc_enable`

- `adc_disable`

- `adc_read`

## Pulse Width Modulation (PWM) Functions

- `pwm_single`

- `pwm_halfbridge`

- `pwm_fullbridge`

- `pwm_update`

## Power Management Functions

## Comparator Functions

## UART Functions

## I<sup>2</sup>C Functions

## SPI Functions

## USB Functions

## In-Circuit Serial Programming (ICSP) Functions

@@NEXT@@ simulator.md @@PREV@@ commandline.md
@@HIGHLIGHT@@
