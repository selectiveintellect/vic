Getting Started With VIC&trade;
================================

Writing VIC&trade; code is similar to writing Bash scripts except for the fact
that there are no functions supported yet in version 0.08.

Here is a quick description of the syntax:
* there is a Main block that is required
* there is a Simulator block that is optional but you can use it to simulate the
  generated PIC assembly code in a supported simulator like `gpsim`
* code generation can be manipulated by pragmas
* the PIC MCU selected can be defined by a single line header
* blocks are defined using braces `{}`
* statements end with a semi-colon `;`
* indentation is personal choice and not a forced choice like that of Python
* you can have multiple statements on a single line if you want
* you can make the code highly readable and follow a set logic
* you can get VIC&trade; code match the logic of a flowchart
* you can use VIC&trade; as an intermediate language and write even higher level
  code in your favorite language like Perl, Python or Ruby and generate
VIC&trade; code from it.

Let us begin with the _hello world !_ programs for the MCU world which is
lighting up an LED. We hope you know what an LED is.

# Hello World ! - lighting up an LED

This example is available in the file `share/examples/helloworld.vic`.

Let us select the PIC MCU P16F690 that comes with the
[PICKit&trade; 2 Starter Kit](http://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=DV164120)
 from Microchip. You may want to look at the data sheet for this MCU to see the
pin configuration and names.

Let us select the pin RC0 to which we want to connect an LED to.

Our code will look like this:
    
    PIC P16F690;
    Main {
        digital_output RC0;
        write RC0, 1;
    }

That&quot;s it ! Just two lines to light up an LED and it is easy to read and
understand what is happening. There is no need to know which registers to
manipulate to switch a pin to digital output or input. There is no need to know
how to write a value to a pin. All you need to know is the names of the pins
which you can get from reading a single page of the datasheet showing the image
of the MCU.

Let us go over each line one at a time to see what
they mean.

`PIC P16F690;` is the one-line header that defines which PIC MCU this program is
targeting. It tells the VIC compiler to verify that the pin names that the user
uses is correct and to generate code appropriately for the MCU.

`Main {` is the _main_ block of code that will be executed by the MCU. This is a
requirement for the code to be generated. You will have to create a `Main`
block.

`digital_output RC0;` is pretty obvious. You are setting pin RC0 of the P16F690
MCU as a digital output. The way MCUs are designed today, each pin can be used
as a digital or analog I/O port at any point of time in the code. Hence we have
an explicit function to set it. This function will generate the appropriate
assembly instructions to set RC0 as a digital output port.

`write RC0, 1;` is a very important line. The `write` function can do various
things. However, in this scenario, we use it to write the value 1 to the pin
RC0. Assuming the LED is connected to RC0. This will set the RC0 digital output
to 1 and the LED will turn on.

`}` is the end of the `Main` block. There is no semi-colon needed at the end of
a block.

Now that we have looked at the code, let us note the basic syntax of a typical
program:

    PIC pic_name;
    block_name {
        function_name argument, argument, argument, ..., argument;
        function_name argument, argument, argument, ..., argument;
        function_name argument, argument, argument, ..., argument;
        function_name argument, argument, argument, ..., argument;
    }

As simple as that. Each function name is just followed by the suppported
arguments for that function. Each block is just a name followed by a brace `{`
containing statements or function calls to pre-defined functions and ending by
another `}`. _TODO: improve this_

An argument can be anything from the MCU pin, MCU port register, strings,
numbers, hexadecimal numbers and blocks themselves.

## Simulating the Hello World program

VIC&trade; also supports simulation of the code. Currently, simulation is
slightly limited and is only supported if the user is using `gpsim` for
simulation. However, more simulators or extended support for `gpsim` will be
added in the future.

To add a simulation code in VIC&trade;, we add a block titled `Simulator` as
below. 

    Simulator {
        attach_led RC0;
        stop_after 1s;
        log RC0;
        logfile "helloworld.lxt";
        scope RC0;
    }

Let us look at the above code and analyse what we are doing.

`attach_led RC0` attaches an LED to the pin RC0 in the simulator.
`stop_after 1s` stops the simulation after 1 second.
`log RC0` logs the output of the pin RC0.
`logfile "helloworld.lxt"` logs the simulation output defined by the `log`
commands in the `Simulator` block. The filename lxt can then be viewed by the
`gtkwave` program to see waveforms of the digital outputs.
`scope RC0` plots the output of the pin RC0 in the in-built software scope
viewer of the simulator. The scope window in `gpsim` is not very good but it
does a good job of real time plotting. For detailed offline analysis, using the
logging mechanism with lxt files and `gtkwave` is a better method.

## Running the helloworld.vic code


