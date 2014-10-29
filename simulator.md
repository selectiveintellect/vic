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

- `stopwatch`

- `sim_assert`

- `autorun`

## Logging

- `log`

- `logfile`

- `scope`

## Wave Simulations

- `stimulate`

## Peripheral Attachments

- `attach_led`

- `attach_led7seg`


@@NEXT@@ examples.md @@PREV@@ functions.md
