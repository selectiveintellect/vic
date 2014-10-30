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

        digital_output <port | pin>;

    This function sets the given MCU port or pin name as a digital output. It
internally will generate code handling the appropriate registers for the MCU to
accomplish this task. A port for a PIC&reg; MCU allows all the pins
corresponding to that port, to be selected at once. An example of a port is `PORTA` and an example of a pin is
`RA0`.

    Examples:

        digital_output PORTA;
        digital_output RC0;

- `write`

    Syntax:

        write <port>, <CONSTANT| variable | port>;
        write <pin>, <CONSTANT | variable | pin>;

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

    Syntax:

        analog_input <port | analog pin>;

    This function sets the given MCU port or pin name as an analog input. It
internally will generate code handling the appropriate registers for the MCU to
accomplish this task. A port for a PIC&reg; MCU allows all the pins
corresponding to that port, to be selected at once. An example of a port is `PORTA` and an example of a pin is
`AN0`. The user is more likely to use a single pin rather than a port for the
analog input.

    Examples:

        analog_input AN0;
        analog_input PORTA; # sets all the capable analog pins only

- `digital_input`

    Syntax:

        digital_input <port | pin>;

    This function sets the given MCU port or pin name as a digital input. This
is needed when a pin is capable of being both an analog or a digital input. For
a pin that is not capable of being a digital input, this function is redundant.
The function will generate code handling the appropriate registers for the MCU to
accomplish this task. A port for a PIC&reg; MCU allows all the pins
corresponding to that port, to be selected at once. An example of a port is `PORTA` and an example of a pin is
`AN0`. The user is more likely to use a single pin rather than a port for the
analog input.

    Examples:

        digital_input RA3;
        digital_input PORTA; # sets all the capable analog pins only

- `debounce`

    Syntax:

        debounce <pin>, Action {
            ## ... do something ...
        };

    Pragmas:

        pragma debounce count = <INTEGER>;
        pragma debounce delay = <time>;

    This function performs [debouncing](https://en.wikipedia.org/wiki/Debouncing#Contact_bounce) of the input on the given MCU pin. The pin
should have been configured as a digital or analog input for this to work
properly. Once the debouncing has completed, the [action block](syntax.html#actions) provided is
invoked by the program.

    The debouncing function can be configured to generate code based on
[pragmas](syntax.html#pragmas). As we note above, two pragmas are accepted. The
`count` pragma uses the given number as the number of possible signals to count
before accepting the input as a positive signal to invoke the `Action` block on.
The `delay` pragma uses the given time to check the signal on the pin
periodically for counting. Default values of the `delay` pragma is 1000
microseconds and `count` pragma is 5.

    If the user does not give any pragmas, the default pragmas are used.

    Examples:

        pragma debounce count = 3;
        pragma debounce delay = 1ms;

        Main {
            digital_input RA3; # we need the pin to be setup as input
            debounce RA3, Action {
                write RA0, 1; # do some action
            };
        }

## Time Management Functions

- `delay`

    Syntax:

        delay <time | variable>;

    This function generates assembly instructions to create a perfect delay (as
verified by the simulator) of the given time argument. When the user provides
the time as a constant, the units expected are `s`, `ms` or `us` for seconds,
milliseconds or microseconds, respectively. If the user does not provide a unit,
`us` is assumed. If the user wants to use a variable, it is recommended to use
the explicit `delay_us`, `delay_ms` or `delay_s` variations of the function
instead.

    Examples:

        delay 1s; # 1 second delay
        delay 2ms; # 2 millisecond delay
        delay 500us; # 500 microsecond delay
        delay 500; # 500 microsecond delay
        delay $something; # $something microseconds delay

- `delay_us`

    Syntax:

        delay_us <INTEGER | variable>;

    This function generates assembly instructions to create a perfect delay (as
verified by the simulator) of the given integer or variable value in microseconds. It is an
explicit instantiation of the `delay` function. It is more useful in scenarios
where the user wants to change the delays using a variable.

    Examples:

        delay_us 500; # 500 microsecond delay
        delay_us $something; # $something microseconds delay

- `delay_ms`

    Syntax:

        delay_ms <INTEGER | variable>;

    This function generates assembly instructions to create a perfect delay (as
verified by the simulator) of the given integer or variable value in milliseconds. It is an
explicit instantiation of the `delay` function. It is more useful in scenarios
where the user wants to change the delays using a variable.

    Examples:

        delay_ms 5; # 5 millisecond delay
        delay_ms $something; # $something milliseconds delay

- `delay_s`

    Syntax:

        delay_s <INTEGER | variable>;

    This function generates assembly instructions to create a perfect delay (as
verified by the simulator) of the given integer or variable value in seconds. It is an
explicit instantiation of the `delay` function. It is more useful in scenarios
where the user wants to change the delays using a variable.

    Examples:

        delay_s 1; # 1 second delay
        delay_s $something; # $something seconds delay

- `hang`

    Syntax:

        hang;

    This function basically generates an instruction that loops infinitely to
itself. It is equivalent to a `Loop {}` invocation. This may be useful in some
scenarios such as to stop any processing if certain conditions are met until the
chip has been restarted or for testing.

    Examples:

        if $failure = TRUE {
            hang; # hang on failure
        }

## Timer and Interrupt Functions

- `timer_enable`

    Syntax:

        timer_enable <timer port>, <frequency>;
        timer_enable <timer port>, <frequency>, ISR {
            ## ... do something ...
        };

    This function has two ways it can be used. Each of these ways are
independent of the other.

    The first syntax line shown simply enables the timer
given by the timer port, such as `TMR0` or `TMR1` or `WDT` of a PIC&reg; MCU, with a
frequency of invoking the timer in `Hz`, `kHz` or `MHz`. Depending on the
PIC&reg; MCU, the frequency may be adjusted to levels acceptable by the MCU. For
example, if an MCU can accept a minimum frequency of 4kHz and the user gives
2kHz, the code generation will still use 4kHz since that is the minimum
acceptable frequency for the MCU.

    Once the timer has been enabled, the user will need to use the `timer` function described in this
section to use the events created by the timer. This can be used if there is a
periodic task that needs to be done in a loop on a timer. The frequency argument is used
to adjust the clock frequency when the timer port on the MCU gets sent a
positive clock signal.

    The second syntax line shown enables the timer and sets it up as an
interrupt handler to invoke the [interrupt service routine](syntax.html#interruptserviceroutines) `ISR` block.
This is different since it is completely asynchronous and the event handling is
done by the MCU itself. There is a different section of the code section where
the interrupt service routine is stored unlike in the `timer` function. This can
be used to use interrupts to handle asynchronous events such as
analog-to-digital converter (ADC) reads or for watchdog timer `WDT` usage.

    Examples:

    The first syntax usage example:

        Main {
            timer_enable TMR0, 4kHz;
            Loop {
                timer Action {
                    # ... do something ...
                };
            }
        }

    The second syntax usage example:

        Main {
            timer_enable TMR0, 8kHz, ISR {
                # .. do something ..
            };
        }

- `timer_disable`

    Syntax:

        timer_disable <timer port>;

    This function disables a timer that had been enabled using `timer_enable`.
It takes the timer port as an argument.

    Examples:

        Main {
            timer_enable TMR0, 4kHz;
            # .. do something ..
            timer_disable TMR0;
        }

- `timer`

    Syntax:

        timer Action {
            # .. do something ..
        };

    This function sets up a synchronous polling event handler for the timer port
that was setup using the `timer_enable` function. If the timer is ready, the
[action block](#syntax.html#actions) is invoked. The timer is ready based on the
pre-scale value given in the `timer_enable` function.

    Examples:

        Main {
            timer_enable TMR0, 8kHz;
            Loop {
                timer Action {
                    # ... do something ...
                };
            }
        }

## Math Functions

- `rol`

    Syntax:

        rol <variable>, <number of bits>;

    This function rotates the value in the variable by the number of bits
specified towards the left. The value in the variable is then updated with the
rotated value.

    Since the rotation does not have an operator like `>>` or `<<` we have a special
function dedicated to it.

    Example:

        Main {
            $var1 = 0x01;
            Loop {
                rol $var1, 1;
            }
        }

- `ror`

    Syntax:

        ror <variable>, <number of bits>;

    This function rotates the value in the variable by the number of bits
specified towards the right. The value in the variable is then updated with the
rotated value.

    Since the rotation does not have an operator like `>>` or `<<` we have a special
function dedicated to it.

    Example:

        Main {
            $var1 = 0x80;
            Loop {
                ror $var1, 1;
            }
        }

- `sqrt`

    Syntax:

        <output variable> = sqrt <input variable>;

    This is a _special_ function since it returns a value and can be used in
expressions directly. This does not modify the value in the input variable
unlike the `ror` or `rol` functions.

    Examples:

        Main {
            $var1 = 100;
            $var2 = sqrt $var1;
            $var2 += sqrt $var2;
        }

## Analog-to-Digital Converter (ADC) Functions

- `adc_enable`

    Syntax:

        adc_enable;
        adc_enable <frequency>;
        adc_enable <frequency>, <analog pin>;

    Pragmas:

        pragma adc right_justify = <0 | 1>;
        pragma adc vref = <0 | 1>;
        pragma adc internal = <0 | 1>;

    This function enables the ADC on the PIC&reg; MCU. It either
takens no arguments or takes a frequency and optionally an analog pin or channel as the argument.
The frequency is the MCU frequency divided by a power of 2 between 1 and 64. It
sets the conversion clock of the ADC. When no frequency is specified, the
default frequency of the MCU is used. When no analog pin is specified the
default analog channel is used. Generally this default channel is `AN0` but that
may change depending on the PIC&reg; MCU being used. The units of frequency are
in `Hz`, `kHz` or `MHz`.

    The function can be configured to generate code based on
[pragmas](syntax.html#pragmas). As we note above, three pragmas are accepted. The
`right_justify` pragma is useful if the ADC result is greater than
8-bits which is the case in many PIC&reg; MCUs. Some MCUs represent these
results in a 10-bit format, and when storing the 10-bits in two 8-bit registers
the user can select whether to right-justify the output or left-justify.
Essentially, this just affects the code generation and the user should **not**
have to use this pragma at all unless they are generating code with `vic` and
then modifying it by hand. The default value for this pragma is `1`. The user may
choose to use `0` as the other possible value.

    The `vref` pragma is used to define if the positive reference voltage is
`V<sub>DD</sub>` of the MCU or an external voltage source on the `V<sub>REF</sub>`
pin. The default value is `0` which is for the `V<sub>DD</sub>` as the reference
voltage source. The value of `1` will select the voltage source from the
`V<sub>REF</sub>` pin on the MCU.

    The `internal` pragma, if set to `1` will choose the internal oscillator of
the ADC instead of the MCU clock. The frequency argument will be ignored if this
is set. The default value is `0`.

    Examples:

        pragma adc right_justify = 1;

        Main {
            adc_enable; # enable the ADC for the default channel
            # .. or for a specific channel at a fixed frequency of 500kHz
            adc_enable 500kHz, AN1;
        }

- `adc_disable`

    Syntax:

        adc_disable;

    This function disables the ADC if it had been enabled earlier, or resets the
enabling of the ADC, if it needs to be enabled again later.

    Examples:

        Main {
            adc_enable;
            # .. do something ..
            adc_disable;
        }

- `adc_read`

    Syntax:

        adc_read <output variable>;

    This function does the conversion when called and once the conversion is
complete, fills the output variable with the converted value. If the output
value is greater than 8-bits the variable size is automatically adjusted to
handle that.

    Examples:

        Main {
            adc_enable;
            # .. do something ..
            adc_read $var1; # read the conversion into $var1
        }

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
