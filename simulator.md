# Simulating VIC&trade; Code

As you have read in the syntax page on the [`Simulator`
block](syntax.html#simulatorblock), VIC&trade; provides integration with a
software simulator for Microchip's PIC&reg; MCUs.

One such simulator is [gpsim](http://gpsim.sourceforge.net/gpsim.html) which we
recommend you install on your operating system.

`gpsim` allows the user to write simple instructions to control the simulation
and to create standard test fragments such as C-style asserts and debugger style
break points, and to add peripherals like LEDs, 7-segment LEDs, switches, and ports
like UART.

To abstract out these instructions and auto-generate `gpsim` specific code, VIC&trade; provides
various in-built functions that will be described in this chapter. This will
enable the user to write testing code in the same file where the `Main` block is
present and keep the relevance of the testing visible.

For details on pragmas used by the simulator refer to the section on
[pragmas](syntax.html#pragmas).

## Simulator Control

- `stop_after`

    Syntax:

        stop_after <time>;

    This function generates code for the simulator to stop running the
simulation after the time given. This is **not** wall clock time but the time
based on the frequency of the MCU. If the MCU cycle rate is 1MHz, then 1 second
will be 10<sup>6</sup> cycles. Once the simulator has completed that many cycles
it will break the run and provide the user a way to either continue the
simulation manually if desired or exit.

    The time values need units like `s`, `ms`, `us` for seconds, milliseconds
and microseconds respectively. If no units are given, microseconds are assumed.

    Examples:

        Simulator {
            # .. do something ..
            stop_after 5s; # stop after 5 seconds
        };

- `stopwatch`

    Syntax:

        stopwatch <time>;

    This function invokes the stopwatch module of the simulator, if it exists,
to allow for the user to measure the actual time taken by the simulator to
execute a VIC&trade; function. This is very useful to test the `delay` function
as noted in the [function reference](functions.html#timemanagementfunctions).

    Examples:

        ## to compare whether the delay 1s instruction works as expected
        Main {
            delay 1s;
        }
        Simulator {
            stopwatch 1s;
        }

- `sim_assert`

    Syntax:

        sim_assert <condition>, <msg string>;
        sim_assert <msg string>;

    This is a _special_ simulator statement in the sense that it can only be
used in the `Main` block and not in the `Simulator` block. Hence it is called
`sim_assert`. It basically informs the simulator as to which location of the
generated code the simulator should create assert break points in, just like a
C-style assert statement.

    Two types of assert statements are accepted: conditional and unconditional.
The message string is optional but is useful for the programmer to know why they
are asserting. The string has to be enclosed in quotes `""`.

    The unconditional assert is like a forced break point and is useful for
debugging applications or stopping simulation once a certain point in the code
has reached, especially if the user does not want to use the `stop_after`
function or even a `Simulator` block.

    Examples:

        Main {
            $var1 = 0xDEADBEEF; # enter a 32-bit value
            sim_assert $var1 == 0xEF, "32-bit is stored as 8-bit";
            sim_assert "*** Stop the simulation ***";
        }

- `autorun`

    Syntax:

        autorun;

    This statement when present in the simulator block will start the simulation
as soon as the generated simulator `.stc` file or `.cod` file is loaded up in the
simulator `gpsim`. Normally, the user will have to manually type the `run`
command first in `gpsim` to do so. Currently, since we do not support any other
simulators yet, this command is specific to `gpsim`. In the future, it may be
redundant.

    Examples:

        Simulator {
            # .. do something ..
            autorun;
        }

## Logging

- `log`

    Syntax:

        log <port | pin> [, <port | pin>];

    This statement will start logging information for the given port or pin on
the MCU. This is needed if the user wants to view the output of the port or pin
on the simulator's oscilloscope utility or using an external utility like
[gtkwave](http://gtkwave.sourceforge.net/). The function takes any number of
ports and pins as arguments, with at least one argument at a minimum.

    Examples:

        Simulator {
            # .. do something ..
            log PORTC, RA0;
        }

- `logfile`

    Syntax:

        logfile <filename>;
        logfile;

    This statement does the logging to a file given as the argument. There is a
special type of logging for `gtkwave` called `LXT` logging that is turned on if
the file name has an extension `.lxt`. Otherwise text based logging is done to
the file. If no filename is provided, the default filename of `vicsim.log` is
used. The filename string has to be enclosed in quotes `""`.

    Examples:

        Simulator {
            # .. do something ..
            logfile "helloworld.lxt";
        }

- `scope`

    Syntax:

        scope <port | pin> [, <port | pin>];

    This function connects the simulator's oscilloscope tool to the list of pins
and ports provided as arguments. It takes any number of arguments, with a
minimum of at least 1. This will turn on the oscilloscope view of the simulator
if it exists. It **has** to be used in conjunction with the `log` command.

    Examples:

        Simulator {
            # .. do something ..
            log PORTC, RA0;
            scope PORTC, RA0;
        }

## Peripheral Attachments

- `attach_led`

    Syntax:

        attach_led <port | pin>, <number>, <color>;
        attach_led <port | pin>, <number>;
        attach_led <port | pin>;

    This function attaches the given number of colored LEDs to the pin or port
name provided. Simulators like `gpsim` allow for a circuit diagram to be
displayed and attachments like LEDs and 7-segment LEDs can be used to display
the workings of code.

    If the color argument is not provided, the default LED color (most likely
`red`) is used. Acceptable colors for `gpsim` are: `red`, `orange`, `green`,
`yellow` and `blue`. If any other string is used as a color, `red` is used.

    If the number argument is not provided it defaults to 1. If a pin is given
and the number is greater than 1 it still attaches only 1 LED. If a port is
given, then depending on how many pins the port is attached to the lower number
is picked. For example, if a port has 4 pins and the user wants to attach 8 LEDs
to the port, then only 4 get attached.

    Examples:

        Simulator {
            # attach 1 green LED to RC0
            attach_led RC0, 1, 'green';
            # attach 4 red LEDs to all the pins in PORTA (RA0-RA3)
            attach_led PORTA, 4, 'red';
            # attach 1 LED of the default color to RB0
            attach_led RB0;
        }

- `attach_led7seg`

    Syntax:

        attach_led7seg <port | pin> [, <port | pin>], <color>;
        attach_led7seg <port | pin> [, <port | pin>];

    This function attaches the in-built 7-segment LED for the simulator if it
exists, such as in `gpsim`. The default color is `red` but the user can specify
any other color as outlined in the `attach_led` function.

    This function takes any number of arguments with any number of pins and
ports as needed by the 7-segment LED. The `gpsim` 7-segment LED needs a minimum
of 5 pins. To use the 7-segment LED of the simulator, the user will need to
manipulate the output pins as per the needs of the simulator. For an example
look at the `share/examples/led7seg.vic` file in the source code or in the
[examples chapter](examples.html#usinga7-segmentled).

    Examples:

        Simulator {
            attach_led7seg RA0, PORTC;
            # .. do something ..
        }



## Wave Simulations

- `stimulate`

    Syntax:

        stimulate <pin>, every <time>, wave [
            <number of cycles>, <value>,
            <number of cycles>, <value>,
             ...
            <number of cycles>, <value>
        ];


    This function allows the user to simulate a pin with a periodic digital wave.

    The period argument denoted by `every <time>` could be optional, but we
force it to be used so that the user knows and understands what they are trying
to express to the simulator.

    The wave argument is basically an array of pairs of numbers, with the first
number being the instance of the time on the X-axis in cycles of the MCU (generally microseconds), followed
by the value of the wave on the Y-axis. Currently supported values are all
integers. Floating point values are not yet supported in VIC&trade;

    For a standard square wave, the values oscillate between `0` and `1`, as
shown in the below example, in the [debouncing a switch
example](examples.html#debouncingaswitch) or in the `share/examples/debouncer.vic` showing how
to simulate a debouncing switch in `gpsim`.

    Examples:

        Simulator {
            # log a pin to view in scope
            log RA3;
            scope RA3;
            # stimulate the pin with an input square wave
            stimulate RA3, every 5s, wave [
                300, 1, 1300, 0,
                1400, 1, 2400, 0,
                2500, 1, 3500, 0,
                3600, 1, 4600, 0
            ];
        }

@@NEXT@@ examples.md @@PREV@@ functions.md
@@HIGHLIGHT@@
