# Getting Started With VIC&trade;

Writing VIC&trade; code is similar to writing Bash scripts except for the fact
that there are no functions supported as of version 0.12.

Here is a quick description of the [syntax](syntax.html):

- there is a Main block that is required
- there is a Simulator block that is optional but you can use it to simulate the
  generated PIC assembly code in a supported simulator like `gpsim`
- code generation properties can be manipulated by pragmas
- the PIC MCU selected can be defined by a single line header
- blocks are defined using braces `{}`
- statements end with a semi-colon `;`
- indentation is personal choice and not a forced choice like that of Python
- you can have multiple statements on a single line if you want
- you can make the code highly readable and follow a set logic
- you can get VIC&trade; code to visually match the logic of a flowchart
- you can use VIC&trade; as an intermediate language and write even higher level
  code in your favorite language like Perl, Python or Ruby and generate
VIC&trade; code from it.

Let us begin with the _Hello World!_ program for the MCU world, which is
lighting up an [LED](https://en.wikipedia.org/wiki/Light-emitting_diode).

## _Hello World!_ - Lighting up an LED

This example is available in the file `share/examples/helloworld.vic`.

Let us select the PIC MCU P16F690 that comes with the
[PICKit&trade; 2 Starter Kit](http://www.microchip.com/DevelopmentTools/ProductDetails.aspx?PartNO=DV164120)
 from Microchip. From the data sheet of this MCU, we can see the following pin
configuration:

![Figure 1. P16F690 Pin Diagram](./images/pinout_P16F690.png)

---

Let us select the pin 16, `RC0`, to which we want to connect an LED to.

Our code will look like this:

<pre><code class="highlight">
<span class="kn">PIC</span> <span class="l">P16F690</span>;
<span class="kd">Main</span> {
    <span class="nf">digital&#95;output</span> <span class="no">RC0</span>;
    <span class="nf">write</span> <span class="no">RC0</span>, <span class="ss">1</span>;
}
</code></pre>

_That's it !_

Just two lines to light up an LED. And, the code is easy to comprehend.

- There is **no** need for the developer to know which registers to
manipulate for switching a pin to digital output or input.
- There is **no** need to know how to manipulate certain output registers
  to write values to a pin.
- All you need to know are the names of the pins which you can get from the pin
  diagram in the MCU's data sheet.

### Understanding The Code

Let us go over each line of the above code to see what
they mean.

1. <code class="highlight"><span class="kn">PIC</span> <span class="l">P16F690</span>;</code>

    This is the one-line header that defines which PIC MCU this program is
targeting. It tells the VIC&trade; compiler to verify the pin names that the
user has used in the code, inform the user if they are wrong and generate custom
assembly code for that specific MCU.

1. <code class="highlight"><span class="kn">Main</span> {</code>

    This is the beginning of the **main** block of code that will be executed by
the MCU. This is a requirement. You will _have_ to create a `Main` block.

1. <code class="highlight"><span class="nf">digital&#95;output</span> <span class="no">RC0</span>;</code>

    The above describes a way for setting pin `RC0` of the P16F690
MCU as a digital output. The way MCUs are designed today, each pin can be used
as a digital or analog I/O port at any point of time in the code. Hence, we have
an explicit function to set it. This function will generate the appropriate
assembly instructions to set `RC0` as a digital output port.

1. <code class="highlight"><span class="nf">write</span> <span class="no">RC0</span>, <span class="ss">1</span>;</code>

    This is a very important line. The `write` function can do various
things. However, in this scenario, we use it to write the value 1 to the pin
`RC0`. Assuming the LED is connected to `RC0`, this will set the pin output
to 1 and the LED will turn on.

1. `}`

    The `}` here denotes the end of the `Main` block. There is **no** semi-colon needed at the end of
a block.

For more details on the language syntax descriptions look at the section on [syntax](syntax.html).

## Simulating the _Hello World!_ program

VIC&trade; also supports simulation of the code. As of version 0.12, only
`gpsim` is supported as a simulator. However, more simulators may be added in
the future.

To add a simulation code in VIC&trade;, we add a block titled `Simulator` as
below. This block has to be added after the `Main` block in the source file.

<pre><code class="highlight">
<span class="kn">Simulator</span> {
    <span class="nf">attach&#95;led</span> <span class="no">RC0</span>;
    <span class="nf">stop&#95;after</span> <span class="ss">1s</span>;
    <span class="nf">log</span> <span class="no">RC0</span>;
    <span class="nf">logfile</span> <span class="s">"helloworld.lxt"</span>;
    <span class="nf">scope</span> <span class="no">RC0</span>;
}
</code></pre>

Let us look at the above code and analyse what we are doing.

1. <code class="highlight"><span class="kn">Simulator</span> {</code>

    This line starts the simulator code block.

1. <code class="highlight"><span class="nf">attach&#95;led</span> <span class="no">RC0</span>;</code>

    This line calls the `attach_led` function to attach an LED to the pin `RC0`
in the simulator.

1. <code class="highlight"><span class="nf">stop&#95;after</span> <span class="ss">1s</span>;</code>

    This line informs the simulator to stop the simulation after the number of
simulated cycles has reached 1 second. Generally, if each instruction cycle takes 1
microsecond to run, then there will be 1 million cycles run by the simulator
before it stops.

1. <code class="highlight"><span class="nf">log</span> <span class="no">RC0</span>;</code>

    This line turns on logging of the pin `RC0`. There are various types of
[logging options](./simulator.html#logging) and the default logging is to a text file.

1. <code class="highlight"><span class="nf">logfile</span> <span class="s">"helloworld.lxt"</span>;</code>

    This line tells the simulator that the logging has to be done in an `LXT`
format for the `gtkwave` application to use. The file name that the logging will
be done to is `helloworld.lxt`, which can then display the waveforms of the
digital outputs using `gtkwave`.

1. <code class="highlight"><span class="nf">scope</span> <span class="no">RC0</span>;</code>

    If the simulator supports displaying a scope, this will show the output pin
`RC0` on the simulator's scope view. This may or may not be necessary if the
user is using the `LXT` file logging option.

    The scope window in `gpsim` is not very sophisticated, but it does a good job
of real time plotting. For detailed offline analysis, use the logging mechanism
with `LXT` files and `gtkwave`.

1. `}`

    The `}` is always used to close an open block as described in the previous
section.


## Saving code as `helloworld.vic`

Let us save both the above code snippets - the `Main` block and the `Simulator`
block into a file called `helloworld.vic`.

<pre><code class="highlight">
<span class="kn">PIC</span> <span class="l">P16F690</span>;
<span class="kd">Main</span> {
    <span class="nf">digital&#95;output</span> <span class="no">RC0</span>;
    <span class="nf">write</span> <span class="no">RC0</span>, <span class="ss">1</span>;
}
<span class="kn">Simulator</span> {
    <span class="nf">attach&#95;led</span> <span class="no">RC0</span>;
    <span class="nf">stop&#95;after</span> <span class="ss">1s</span>;
    <span class="nf">log</span> <span class="no">RC0</span>;
    <span class="nf">logfile</span> <span class="s">"helloworld.lxt"</span>;
    <span class="nf">scope</span> <span class="no">RC0</span>;
}
</code></pre>

![Figure 2. `helloworld.vic` in a Terminal](images/HelloworldCode.png)

---

## Building the code

Compiling VIC&trade; code is really easy. To compile the file `helloworld.vic` we run
the following command:

    $ vic helloworld.vic -o helloworld.asm

This creates the PIC assembly file that the user can then manipulate further if
they want to. Then the user compiles this the standard way using `gputils`.

    $ gpasm -o helloworld.o helloworld.asm
    $ gplink -m -o helloworld.hex helloworld.o

A sample make file is provided in the source code path
`share/examples/GNUmakefile` for the user to take advantage of. The makefile is very
generic and the user can just use it for their own VIC&trade; code. It compiles
any file present in the same directory that has the extension `.vic`.

## Running the Simulator code

When compiling with `gputils` a file with the extension `.cod` is generated. If
you're using the `GNUmakefile` to compile the code, then a file `.stc` is also
generated.

The contents of `helloworld.stc` are pretty simple.

    $ cat helloworld.stc
    load s helloworld.cod

The user can manually create this file as well.

This file can be loaded in `gpsim` using the command:

    $ gpsim helloworld.stc

This will load the `helloworld.cod` file into the `gpsim` memory and it is ready to
run. However, the user has to type the `run` command in `gpsim` to do that.

    gpsim> run

This will start the simulator run and the user can then view the LED being lit.

Another way to auto-start the simulation is to have the following contents in
the `helloworld.stc` file. This can avoid the manual `run` invocation in
`gpsim`.

    $ cat helloworld.stc
    load s helloworld.cod
    run

Depending on the task being simulated, you may or may not want an auto-started
simulation.

![Figure 3. View of `gpsim` before run](images/HelloworldSimBefore.png)

---

![Figure 4. View of `gpsim` after run](images/HelloworldSimAfter.png)

---

## Running the code on the PIC itself

For the [PICKit 2 Starter Kit](http://www.microchip.com/pickit2/), there is an open source software called
[`pk2cmd`](pk2cmd.html)
that can be used on Linux and Mac OS X to copy the `.hex` file generated onto the
MCU using PICKit 2 Starter Kit. We have **not** tried with the PICKit 3 Starter Kit, but the user can
experiment with Microchip's IDE or [Piklab](http://piklab.sourceforge.net/) to perform the writing.

The user can also combine the code generated by VIC&trade; with Microchip's IDE or Piklab, and use
it that way instead of using `gputils`. However, we do **not** support Microchip's
simulator yet as part of VIC&trade;. We _may_ choose to do it in the future.

@@NEXT@@ syntax.md @@PREV@@ install.md
