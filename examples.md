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

    # enable gpsim as a simulator
    pragma simulator gpsim;

    Main {
        digital_output RC0; # mark pin RC0 as output
        write RC0, 0x1; # write the value 1 to RC0
        sim_assert RC0 == 0x1, "Pin RC0 should be 1";
    }

    Simulator {
        attach_led RC0;
        stop_after 1s;
        logfile "helloworld.lxt";
        log RC0;
        scope RC0;
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

    Simulator {
        stopwatch 1ms;
    }

## Blinking an LED

This example blinks an LED and can be found in the file
`share/examples/blinker.vic`.


    PIC P16F690;

    # enable gpsim as a simulator
    pragma simulator gpsim;

    Main {
         digital_output RC0;
         Loop {
             write RC0, 1;
             delay 1s;
             write RC0, 0;
             delay 1s;
         }
    }

    Simulator {
        attach_led RC0, 1, 'green';
        stop_after 30s;
        logfile;
        log RC0;
    }

## Rotating over LEDs

This example rotates the lighting up of an LED in a loop with a port connected
to 4 LEDs. It can be found in the file `share/examples/rotater.vic`.


    PIC P16F690;

    # enable gpsim as a simulator
    pragma simulator gpsim;

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

    Simulator {
        attach_led PORTC, 4; # attach 4 LEDs to PORTC on RC0-RC3;
        stop_after 60s;
        logfile "rotater.lxt";
        log PORTC;
        scope PORTC;
    }

## Using a 7-segment LED

This example demonstrates how to use a simulator 7-segment LED, a look up table
and array indexing to periodically change digits in the LED. Note that the LED
look up table is specific to `gpsim`, and to use a real 7-segment LED these
values may have to be changed as per the chosen 7-segment LED. This is also
found in the source code as the file `share/examples/led7seg.vic`.

    PIC p16f690;

    pragma variable export;
    # enable gpsim as a simulator
    pragma simulator gpsim;

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

    Simulator {
        attach_led7seg RA0, PORTC;
        stop_after 5s;
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
            if $var1 != FALSE && $var2 != FALSE {
                write PORTC, 1;
                $var1 = !$var2;
            } else if $var1 || $var2 {
                write PORTC, 2;
                $var2 = $var1;
            } else if !$var1 {
                write PORTC, 4;
                $var2 = !$var1;
            } else if $var2 {
                write PORTC, 4;
                $var2 = !$var1;
            } else {
                write PORTC, 8;
                $var1 = !$var2;
            };
            $var3 = 0xFF;
            while $var3 != 0 {
                $var3 >>= 1;
            }
        }
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
                if $dummy <= 0x0F {
                    break;
                }
            }
            while $dummy > 0 {
                $dummy >>= 1;
                write PORTC, 3;
                continue;
            }
            if $dummy == TRUE {
                write PORTC, 2;
                break;
            } else {
                write PORTC, 4;
                continue;
            }
        }
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


This brings us to the end of the list of examples.

@@NEXT@@ index.md @@PREV@@ simulator.md
@@HIGHLIGHT@@
