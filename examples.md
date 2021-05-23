# Examples

This chapter lists a variety of examples demonstrating how to use VIC&trade;.
Most of these examples can be found in the `share/examples` folder in the source
code and in your installation.

Wherever necessary the code is explained. Most of the code is quite obvious and
very readable.

## Hello World!

This example lights up an LED and can be found in the file
`share/examples/helloworld.vic`. We also demonstrate how to verify everything
with a simulator `sim_assert` statement and other statements to visually display
the lighting up of the LED in the simulator interface.

    PIC P16F690;

    Main {
        digital_output RC0; # mark pin RC0 as output
        write RC0, 0x1; # write the value 1 to RC0
        sim_assert RC0 == 0x1, "Pin RC0 should be 1";
    }

## Synchronous Time Delays

This is a generic piece of code that can be used to test whether the [`delay`
functions](functions.html#timemanagementfunctions) work as expected and can create the exact delay needed. That's where
the simulators [`stopwatch` function](simulator.html#simulatorcontrol) come in
handy. The code is available in the file `share/examples/delay.vic`.

    PIC P16F690;

    Main {
        delay 1ms;
        sim_assert "*** EARLY STOP ***";
    }

## Blinking an LED

This example blinks an LED and can be found in the file
`share/examples/blinker.vic`.


    PIC P16F690;

    Main {
         digital_output RC0;
         Loop {
             write RC0, 1;
             delay 1s;
             write RC0, 0;
             delay 1s;
         }
    }

## Rotating over LEDs

This example rotates the lighting up of an LED in a loop with a port connected
to 4 LEDs. It can be found in the file `share/examples/rotater.vic`.


    PIC P16F690;

    Main {
        digital_output PORTC;
        $display = 0x08; # create a 8-bit register by checking size
        sim_assert $display == 0x08, "$display should be 0x08";
        Loop {
            write PORTC, $display;
            delay 100ms;
            # improve this depiction
            # circular rotate right by 1 bit
            ror $display, 1;
        }
    }


## Using a 7-segment LED

This example demonstrates how to use a simulator 7-segment LED, a look up table
and array indexing to periodically change digits in the LED. Note that the LED
look up table is specific to `gpsim`, and to use a real 7-segment LED these
values may have to be changed as per the chosen 7-segment LED. This is also
found in the source code as the file `share/examples/led7seg.vic`.

    PIC p16f690;

    pragma variable export;

    Main {
        $led7 = table [ 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D,
                  0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, # this is gpsim specific
                  0x58, 0x5E, 0x79, 0x71 ];
        $digit = 0;
        digital_output PORTA;
        digital_output PORTC;
        write PORTA, 0;
        Loop {
            write PORTC, $led7[$digit];
            $digit++;
            $digit &= 0x0F; # bounds check
        }
    }


## Conditional Loops

This example demonstrates how to use [loops](syntax.html#unconditionalloops) and [conditional blocks](syntax.html#conditionalblocks) in VIC&trade;.
It is available in the source code as the file `share/examples/conditional.vic`.
The simulator code is left as an exercise for the reader.

    PIC P16F690;

    Main {
        digital_output PORTC;
        $var1 = TRUE;
        $var2 = FALSE;
        Loop {
            if ($var1 != FALSE && $var2 != FALSE) {
                $var1 = !$var2;
                sim_assert $var1 == FALSE, "$var1 == FALSE. block 1";
                write PORTC, 1;
                sim_assert "pause. block 1";
            } else if $var1 || $var2 {
                $var2 = $var1;
                write PORTC, 2;
                sim_assert "pause. block 2";
            } else if !$var1 {
                $var2 = !$var1;
                write PORTC, 4;
                sim_assert "pause. block 3";
            } else if $var2 {
                $var2 = !$var1;
                write PORTC, 4;
                sim_assert "pause. block 4";
            } else {
                write PORTC, 8;
                $var1 = !$var2;
                sim_assert "pause. block 5";
                break;
            };
            $var3 = 0xFF;
            while $var3 != 0 {
                $var3 >>= 1;
            }
        }
        sim_assert "pause. end of main";
    }


## Breaking Out of Nested Loops

This example demonstrates how to use nested loops and the [`break` and `continue`
statements](syntax.html#conditionalblocks) to change the execution logic. The simulator code is left as an
exercise to the reader. The code is available in the file
`share/examples/loopbreak.vic`.

    PIC P16F690;

    Main {
        digital_output PORTC;
        Loop {
            $dummy = 0xFF;
            while $dummy != 0 {
                $dummy >>= 1;
                write PORTC, 1;
                sim_assert $dummy > 0x0F, "dummy is > 0x0F";
                if $dummy <= 0x0F {
                    break;
                }
            }
            sim_assert $dummy == 0x0F, "dummy is 0x0F";
            while $dummy > 1 {
                $dummy >>= 1;
                write PORTC, 3;
                continue;
            }
            sim_assert $dummy == 1, "dummy is 1";
            if $dummy == TRUE {
                write PORTC, 2;
                break;
            } else {
                write PORTC, 4;
                continue;
            }
        }
        sim_assert "we have exited the infinite loop 1";
        # we have broken from the loop
        while TRUE {
            write PORTC, 0xFF;
        }
    }


## Mathematical Operations

This code demonstrates the various mathematical operations supported by
VIC&trade; along with verifying them using the simulator's [`sim_assert`
function](simulator.html#simulatorcontrol). All the mathematics is done in 8-bit
mode and the code is available in the file `share/examples/math8bit.vic`.

    PIC P16F690;

    pragma variable bits = 8;
    pragma variable export;

    Main {
        $var1 = 12345;
        sim_assert $var1 == 57, "12345 was placed as 57 due to 8-bit mode";
        $var2 = 113;
        $var3 = $var2 + $var1;
        sim_assert $var3 == 170, "57 + 113 = 170";
        $var3 = $var2 - $var1;
        sim_assert $var3 == 56, "113 - 57 = 56";
        $var3 = $var2 * $var1;
        sim_assert $var3 == 41, "113 * 57 = 41";
        $var2 = $var2 * 5;
        sim_assert $var2 == 53, "113 * 5 = 565 => 53 in 8-bit mode";
        $var3 = $var2 / $var1;
        sim_assert $var3 == 0, "53 / 57 = 0 in integer mathematics";
        $var3 = $var2 % $var1;
        sim_assert $var3 == 53, "53 % 57 = 53";
        --$var3;
        sim_assert $var3 == 52, "--53 = 52";
        ++$var3;
        sim_assert $var3 == 53, "++52 = 53";
        $var4 = 64;
        $var4 -= $var1;
        sim_assert $var4 == 7, "64 - 57 = 7";
        $var3 *= 3;
        sim_assert $var3 == 159, "53 * 3 = 159";
        $var2 /= 5;
        sim_assert $var2 == 10, "53 / 5 = 10";
        $var4 %= $var2;
        sim_assert $var4 == 7, "7 % 10 = 7";
        $var4 = 64;
        $var4 ^= 0xFF;
        sim_assert $var4 == 0xBF, "64 ^ 0xFF = 0xBF";
        $var4 |= 0x80;
        sim_assert $var4 == 0xBF, "0xBF | 0x80 = 0xBF";
        $var4 &= 0xAA;
        sim_assert $var4 == 0xAA, "0xBF & 0xAA = 0xAA";
        $var4 = $var4 << 1;
        sim_assert $var4 == 84, "0xAA << 1 = 340 which is 84 in 8-bit mode";
        $var4 = $var4 >> 1;
        sim_assert $var4 == 42, "84 >> 1 = 42";
        $var4 <<= 1;
        sim_assert $var4 == 84, "42 << 1 = 84";
        $var4 >>= 1;
        sim_assert $var4 == 42, "84 >> 1 = 42";
        $var5 = $var1 - $var2 + $var3 * ($var4 + 8) / $var1;
        sim_assert $var5 == 47, "57 - 10 + ((159 * (42 + 8)) & 0xFF) / 57";
        $var7 = 13;
        $var5 = ($var1 + (($var3 * ($var4 + $var7) + 5) + $var2));
        sim_assert $var5 == 113,
            "57 + (((159 * (42 + 13)) & 0xFF + 5) + 10) = 113";
        $var6 = 19;
        $var8 = ($var1 + $var2) - ($var3 * $var4) / ($var5 % $var6);
        sim_assert $var8 == 66, "(57 + 10) - ((159 * 42) & 0xFF) / (113 % 19)";
        # sqrt is a modifier
        $var3 = sqrt $var4;
        sim_assert $var3 == 6,
            "sqrt(42) = 6.4807 which is 6 in integer mathematics";
        sim_assert "*** Completed the simulation ***";
    }

## Debouncing a Switch

This example shows how to debounce a pin input `RA3` connected to a switch and
simulate the pressing of the switch using the [`stimulate`
statement](simulator.html#wavesimulations). The example can be found in
`share/examples/debouncer.vic`.

    PIC P16F690;

    pragma debounce count = 5;
    pragma debounce delay = 1ms;

    Main {
        digital_output PORTC;
        digital_input RA3;
        $display = 0;
        Loop {
            debounce RA3,
            Action {
                ++$display;
                write PORTC, $display;
            };
        }
    }


## Analog-to-Digital Converter (ADC) Test

This example demonstrates how to use the ADC of the MCU to read analog
information into a digital variable. We also use that variable to adjust the
delays to modify the speed of the blinking of an LED connected to the pin `RC0`.
In our case, we tested this on physical hardware where the pin `AN0` was
connected to a potentiometer switch (variable rotation) and the pin `RC0` was
connected to an LED. The code can be found in `share/examples/adctest.vic`.

The difference in use of the [`stimulate`
statement](simulator.html#wavesimulations) is that it accepts floating point
values. When the values are floating point then the stimulus is assumed to be
analog.


    PIC P16F690;

    pragma adc right_justify = 0;
    Main {
        digital_output RC0;
        analog_input AN0;
        adc_enable 500kHz, AN0;
        Loop {
            adc_read $display;
            delay_ms $display;
            write RC0, 1;
            delay_ms $display;
            write RC0, 0;
            delay 100us;
        }
    }


## Variable Rotation of LEDs

In this example we use the ADC to change the speed of rotation of 4 LEDs
connected to the `PORTC` (pins `RC0-RC7`) of the MCU. The value is read from the
ADC on the `AN0` analog pin connected to a variable potentiometer which changes
the speed of the lights blinking between the 4 LEDs following the right rotation
pattern of bits. It is an enhanced version of the [rotating over
LEDs](#rotatingoverleds) example. This example can be found in `share/examples/varrotate.vic`.

    PIC P16F690;

    pragma adc right_justify = 0;

    Main {
        digital_output PORTC; # all pins
        analog_input RA3;
        adc_enable 500kHz, AN0;
        $display = 0x08; # create a 8-bit register
        Loop {
            write PORTC, $display;
            adc_read $userval;
            $userval += 100;
            delay_ms $userval;
            ror $display, 1;
        }
    }


## Reversing LEDs on Switch Press

This is a combination of the [debouncing a switch](#debouncingaswitch) example and the [variable
rotation](#variablerotationofleds) example. In this we assume that a push button switch has been connected
to the `RA3` pin, 4 LEDs have been connected to each pin on `PORTC` (pins `RC0-RC7`)
and that the analog channel/pin `AN0` is connected to a variable potentiometer.

When the user presses a switch the direction of lighting up the 4 LEDs changes
from left to right and back. When the user rotates the potentiometer, the speed
of blinking of the 4 LEDs changes accordingly. This example can be found in
`share/examples/reversible.vic`. 

    PIC P16F690;

    pragma debounce count = 2;
    pragma debounce delay = 1ms;
    pragma adc right_justify = 0;

    Main {
        digital_output PORTC;
        digital_input RA3;
        analog_input AN0;
        adc_enable 500kHz, AN0;
        $display = 0x08; # create a 8-bit register
        $dirxn = FALSE;
        Loop {
            write PORTC, $display;
            adc_read $userval;
            $userval += 100;
            delay_ms $userval;
            debounce RA3, Action {
                $dirxn = !$dirxn;
            };
            if $dirxn == TRUE {
                rol $display, 1;
            } else {
                ror $display, 1;
            };
        }
    }


## Timer Usage

This example demonstrates how to use the [synchronous timer
functions](functions.html#timerandinterruptfunctions) to perform the same task
as the [`delay` functions](functions.html#timemanagementfunctions). This is very
similar to the [Rotating over LEDs example](#rotatingoverleds), except that
instead of rotating the blinking of the LEDs, it displays the binary values
ranging from `0-15` on the LEDs connected to `PORTC` (pins `RC0-RC7`). This can be
found in the `share/examples/timer.vic` file.

The timer features, if used, are automatically simulated by the simulator and
the user does not have to create any fake stimuli for it.

    PIC P16F690;

    Main {
        digital_output PORTC;
        $display = 0;
        timer_enable TMR0, 4kHz;
        Loop {
            timer Action {
                ++$display;
                write PORTC, $display;
            };
        }
    }


## Interrupt Service Routine Usage

This example demonstrates how to use the [interrupt service
routines](functions.html#timerandinterruptfunctions) to accomplish the same task
as in the [Reversing LEDs on Switch Press](#reversingledsonswitchpress) example.
This is available in the `share/examples/interrupt.vic` file. As you can see,
the ADC is beign read using the interrupt. This is more efficiently implemented
as checking the ADC is now done on an event-based timer instead of using a synchronous MCU loop.

The interrupt handling is automatically simulated by the simulator, but the
external stimuli like debouncing the switch and analog stimulus have to still be
added by the user.

    PIC P16F690;

    pragma debounce count = 2;
    pragma debounce delay = 1ms;
    pragma adc right_justify = 0;

    Main {
        digital_output PORTC;
        analog_input AN0;
        digital_input RA3;
        adc_enable 500kHz, AN0;
        $display = 0x08; # create a 8-bit register
        $dirxn = FALSE;
        timer_enable TMR0, 4kHz, ISR { #set the interrupt service routine
            adc_read $userval;
            $userval += 100;
        };
        Loop {
            write PORTC, $display;
            delay_ms $userval;
            debounce RA3, Action {
                $dirxn = !$dirxn;
            };
            if ($dirxn == TRUE) {
                rol $display, 1;
            } else {
                ror $display, 1;
            };
        }
    }


## Reading From Pins

The reading from pins examples are in the files `share/examples/reader.vic`,
`share/examples/reader_pin.vic` and `share/examples/reader_port.vic`.

Reading is also supported in the simulator by simulating an input read. Each of
these examples demonstrate the various ways of reading from a pin or a port
using direct read, `Action` block read or `ISR` read.

### Direct Read

This example reads from pin `RC0` and writes to pin `RC1` the value it has read.
The wave stimulus can be seen in the simulator's scope as well.

    PIC P16F690;

    Main {
        digital_input RC0;
        digital_output RC1;
        read RC0, $value;
        read RC0, Action {
            $value = shift;
            write RC1, $value;
        };
        sim_assert $value == 1;
    }

### Interrupt-on-Change Read

This example demonstrates using the interrupt-on-change feature of MCU P16F690's
pin `RA0`. We simulate a wave after a few microseconds that lasts about 2000
microseconds and then see on the scope if the wave has been replicated on pin
`RC0` with a delay. This example is in `share/examples/reader_pin.vic`. A
similar example is in `share/examples/reader_port.vic`.


    PIC P16F690;

    Main {
        digital_output RC0;
        digital_input RA0;
        read RA0, ISR {
            $value = shift;
            write RC0, $value;
        };
    }


## Pulse Width Modulation (PWM)

### Single PWM

The _single_ PWM example can be found in `share/examples/pwm2.vic`. This example
starts a PWM duty cycle at `20%` and then updates it to `30%`.

The PWM is automatically simulated by the simulator and the user just has to
attach an LED and/or a scope to view the output.

    PIC P16F690;

    Main {
        pwm_single 1220Hz, 20%, CCP1;
        delay 5s;
        pwm_update 1220Hz, 30%; # update duty cycle
        delay 5s;
    }

### Half-bridge and Full-bridge Modes

This example can be modified to run all the different PWM modes by uncommenting
the appropriate line with the required `pwm_*bridge` function call. It can be found in
`share/examples/pwm.vic`. Here we see the _half bridge_ mode being used and
uncommenting the other lines will turn on the forward or reverse _full bridge_
modes.

    PIC P16F690;

    Main {
        pwm_halfbridge 1220Hz, 20%, 4us;
        #pwm_fullbridge 'forward', 1220Hz, 20%;
        #pwm_fullbridge 'reverse', 1220Hz, 20%;
    }


This brings us to the end of the list of examples.

@@NEXT@@ simulator.md @@PREV@@ functions.md
@@HIGHLIGHT@@
