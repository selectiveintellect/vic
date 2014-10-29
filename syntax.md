# VIC&trade; Syntax

Now that we have looked at some example code, let us describe more in detail the
various syntactical details of VIC&trade;.

VIC&trade; syntax is very much like Unix shell scripting with many similarities
and some notable differences.

A general VIC&trade; code file will have the following types of _statements_:

- [**PIC Header**](#picheader): This is a statement defining which Microchip's PIC&reg; MCU the code is targeting
  by default. This enables the `vic` compiler to generate the correct target
assembly code.
- [**Pragmas**](#pragmas): These are statements that are specific to the code that the user
  is writing and informs the `vic` compiler how to optimize or select certain
traits for the assembly generation. For example, the user can specify a variable
to be 16-bits, and all computations with that variable will generate code doing
16-bit mathematics.
- [**Comments**](#comments): Comments are supported in VIC&trade; like any other
  scripting language.
- [**Variables, Constants and Identifiers**](#variablesconstantsandidentifiers): Many types of variables and identifiers are
  supported.
- [**Blocks**](#blocks): All code that will run on the MCU will have to be enclosed in
  named blocks denoted by `{}`. There are many types of blocks supported:
    - [Main](#mainblock)
    - [Conditional Blocks](#conditionalblocks)
    - [Unconditional Loops](#unconditionalloops)
    - [Actions](#actions)
    - [Interrupt Service Routines](#interruptserviceroutines)
    - [Simulator](#simulatorblock)
- [**Functions**](#functions): Various in-built functions are present as part of
  VIC&trade; which will be explained in the function [reference](functions.html).
- [**Operations**](#operations): Arithmetic, assignment, bitwise, complement, logical and unary operations are described
  here.

A typical VIC&trade; program is arranged in the following way:

    PIC pic_name;
    pragma pragma_type pragma_values;
    Main {
        # user invokes functions
        function_name argument, argument, argument, ..., argument;
        function_name argument, argument, argument, ..., argument;
        function_name argument, argument, argument, ..., argument;
        function_name argument, argument, argument, ..., argument;
        ## maybe the user wants to add a loop to perform a certain function
        ## programs do not need to have loops.
        Loop {
            function_name argument, argument, ..., argument;
        }
    }
    ## optional simulator block
    Simulator {
        # special simulator functions
        function_name argument, argument, argument, ..., argument;
        function_name argument, argument, argument, ..., argument;
    }

We shall now describe each of these above items in detail below.

## PIC Header

The PIC header is a single line statement that begins the program. It is a
**required** statement and tells the `vic` compiler and the program author which PIC
MCU is being targeted.

The general syntax of the PIC header is as below:

    PIC <MCU name>;

The name of the PIC&reg; MCU used is case insensitive although the
keyword <code class="highlight"><span class="kn">PIC</span></code> is case sensitive.

Even though the PIC name is required, the `vic` compiler allows the user to
change the name of the PIC&reg; MCU on the [commandline](commandline.html) using the `-p` option.

Thus the same code file can be compiled to various PIC&reg; MCU assembly targets by
changing the PIC&reg; MCU name at runtime, without editing the code.

## Pragmas

Pragmas are _optional_ statements provided by the user to fine tune code
generation performed by the compiler. The user should use pragmas to inform the
compiler of specific code generation traits or properties. Depending on the
function being used, it may or may not have a pragma associated with it.

All pragmas start with the keyword <code class="highlight"><span class="kn">pragma</span></code>.
The general syntax of a pragma statement is one of the two types:

    pragma <pragma type> <property> = <value>;
    pragma <pragma type> <property>;

Some pragma types have properties that are key-value pairs, and some pragma
types have properties which act as the values for the pragma type itself.

General pragma types are described as follows:

1. `simulator`

    The simulator pragma type defines the type of simulator that the
`vic` compiler will be generating target code for. By default, if the
pragma is not given, the simulator code will be generated for the default
simulator. Otherwise, the property of this pragma type is the name of any of the
supported simulators.

    Currently, since only `gpsim` is supported the default simulator is also
`gpsim`. Hence any of the following statments are valid statements:

        pragma simulator gpsim;
        pragma simulator default;

    To disable code generation of the simulator, in the scenario that `gpsim` is not
installed, such as on Microsoft Windows&reg; the user can use the following
pragma:

        pragma simulator disable;

1. `variable`

    The variable pragma type is used to define the bit-width of either all
variables, or only certain variables, and also handles exporting of variables to
the global namespace in the code generated, for use by [simulator statements](simulator.html) like
`sim_assert`.

    To export all variables to the global namespace, you have to use the below
pragma:
     
        pragma variable export;

    To set the bit width of all variables to be 16, you have to use the below
pragma:

        pragma variable bits = 16;

    By default the bit width of all variables is a property of the MCU, and the
most common value is 8. The different types of bit widths supported are 8, 16,
32 and 64.

    To set the bit width of a specific variable `$myvar` to be a value greater than 8
such as 32, you can use:

        pragma $myvar bits = 32;

    Note the difference the above two pragma lines, when you use the special
pragma type `variable`, the property `bits` or `export` is set for all
variables. When you use the pragma type as the variable name `$myvar`, the
property `bits` or `export` is set only for that variable.

    This pragma can be used when handling overflows during arithmetic
operations. It also can be used to optimize code generation and manage memory as
some MCUs may have very small amounts of free memory.

1. Function-specific

    There are various pragmas that are function specific and will be described in
the [function reference](functions.html) with the function descriptions.

## Comments

Like any scripting language such as Perl, Python, Ruby or shell, VIC&trade;
accepts anything that follows a `#` to be a comment as long as it is not
enclosed within quotes.

The following are comments:

    # this is a comment
    some_random_statement ....; # this part is a comment too
    
The following are not comments:

    $var = "this is a string # this is not a comment";

Empty lines and lines with all spaces are also considered as comments by the `vic` compiler and they
are ignored.

## Variables, Constants and Identifiers

VIC&trade; supports user defined variables, string and numeric literals,
constant identifiers such as MCU pin numbers and
general identifiers such as function names, conditional keywords and block names.

All variables should start with a `$` sign followed by an alphanumeric string of
any length. The name of the variable has to start with an alphabet in the set 
`[A-Za-z]`. The variable names are case insensitive to maintain compatibility
with the MCU assembly variable handling.

    $var1 = 20;
    $var2 = "hello";
    $var3 = 0xAB;

There are **no** such things as variable declarations. The type of the variable
is automatically inferred by the `vic compiler. The first time a particular
variable is used is where it gets _declared_. Currently, as of version 0.12, all
variables are global. There is no scoping implemented. However, to have a
variable be accessed by a simulator, they have to be exported using the pragma.

String and numeric literals are supported as in any language. Strings can be
enclosed within single or double quotes. Numeric literals supported are
integers, hexadecimal numbers and booleans. The boolean keywords are `true` and
`false` and they are case insensitive.

Numeric constants can also accept units such as `s` for seconds, `ms` for
milliseconds, `us` for microseconds, `Hz` for Hertz, `kHz` for kilo Hertz,
`MHz` for mega Hertz and `%` for percent.

    $my_timer = 1s;
    $frequency = 4MHz;
    $pwmcycle = 20%;

The language keywords are: `if`, `else` and `while`. They are case _sensitive_.

Constants are validated keywords that are not the language keywords but
represent some aspect of the MCU being targeted. Generally they are the pin
names, such as those shown in the [pin diagram](gettingstarted.html#savingcodeashelloworld.vic) of the MCU.
Many other standard names are also accepted such as:

- GPIO port names
- Timer register names
- UART/SPI/I<sup>2</sup>C port names
- A/D converter port names
- Comparator names
- Clock pins
- PWM pins

It depends on the MCU being handled and the user may need to refer to the pin listings from the data sheet for their MCU or use
the `vic` compiler's [commandline](commandline.html) options to list the valid
pin constants. Some sample constants look like `RC0`, `PORTA`, `TMR0`, `USART`.

Other general identifiers are standard alphanumeric strings which start with an
alphabet in the range `[A-Za-z]` followed by any number of alphanumeric
characters. These identifiers are used for block names and function names. 

## Blocks

Code in VIC&trade; is arranged in _named_ blocks enclosed within `{}`. There are
many different types of blocks but the most important and required block is the
[`Main` block](#mainblock).

### Main Block

For any code to be generated, it has to be contained in the `Main` block. The
`Main` block has to be written after all the pragmas have been stated in the
code.

    PIC <MCU Name>;
    ## ... pragmas go here...
    Main {
        # ... some statements that do something ...
    }

All the statements in the `Main` block work similar in concept to the C
language's `main()` function. This is where the MCU code begins. The `Main`
block can contain any statements or other types of blocks.

### Conditional Blocks

Two types of conditional statements are supported: `if-else` statements and
`while` loops. Unconditional or forever loops are supported as well and are
described in the [next section](#unconditionalloops).

The syntax of the `if-else` blocks are similar to that of the C language or
Javascript but the parentheses around conditions is optional. Precedence of the operators goes
from left to right. The `else` and `else if` blocks are always optional.

    if <conditions> {
        # .. statements ..
    } else if <conditions> {
        # .. statements ..
    # ... any number of else-if statements can go here ...
    } else {
        # .. statements ..
    }

A sample example is below:

    if $var1 == true && $var2 == false {
        # .. do something ..
    } else if ($var1 == false && $var2 == true) {
        # .. do something ..
    } else {
        # .. do something else ..
    }

In a similar fashion, the `while` loops are like that of the C language or
Javascript but the parentheses around conditions is optional.

    while $var1 < 30 {
        # .. do something ..
        $var1++;
    }

The `while` loop accepts the `break` and `continue` statements as in the C
programming language, and they have the same functionality. The `if-else` block
also accepts the `break` statement to allow the user to break out of the
inner-most loop that the code instructions might be in. This is very useful for
conditional breaks out of nested loops.

A good example of the usage of these statements is in the file
`share/examples/conditional.vic` and `share/examples/loopbreak.vic`.

### Unconditional Loops

Most microcontroller programming involves forever loops or unconditional loops,
where certain tasks are being done by the microcontroller forever until the
power is turned off.

To account for this common situation, VIC&trade; has a special block construct
`Loop{}`. This allows the `vic` compiler to automatically create the jump
assembly instructions to manage the looping. Any blocks contained within the
`Loop{}` block are also automatically managed by the compiler. The `Loop{}`
construct accepts the `break` and `continue` statements.

Nested `Loop{}` blocks are very useful in certain applications.

The `Loop{}` construct is the same as `while true {}` but instead of making it
look ugly, we felt the need to make it obvious.

A simple loop construct looks like this:

    Loop {
        # ... do something ...
    }

A nested loop construct looks like this:


    Loop {
        # ... do something ...
        # ... enter inner loop ...
        Loop {
            # ... do something ...
            if <some conditions> {
                # ... do something maybe ...
                break; # break out of inner loop
            }
        }
        # ... back to outer loop ...
    }

A simple example of a forever loop is in `share/examples/blinker.vic` in the
source code.

### Actions

Certain in-built VIC&trade; functions call for certain user-defined callbacks to
be executed when a condition is met or an event is triggered. This allows for
VIC&trade; code to natively support events. Such callbacks blocks are called _Actions_.

A typical `Action` block looks like this:

    function_name argument, ..., Action {
        # .. do something here ...
    };

`Action` blocks are like any other block where the user adds regular statements to
the block and they get executed. Variables outside of the `Action` block can be
accessed in the `Action` block and those inside the block can be accessed
outside it as well.

Refer the [function reference](functions.html) to see which functions support
`Action` blocks.

### Interrupt Service Routines

Interrupt Service Routines (ISR) are similar to `Action` blocks except they are
invoked based on the interrupt handling of the MCU. One common usage of ISRs are
with timers. The ISR block starts with the `ISR` keyword.

A typical `ISR` block for a timer looks like this:

    timer_enable TMR0, 256, ISR {
        # .. do something ..
    };

An advantage of having an `ISR` block is for the `vic` compiler to handle
various different ISRs added by the user be managed correctly without errors.

Multiple `ISR` blocks are supported in a single program with this feature. 

### Simulator Block

Simulator test benches can be created for the VIC&trade; program and this code
must reside in the `Simulator` block. Except for the `sim_assert` instruction
which adds C-style assert statements to the `Main` block and its nested blocks,
all other simulator statements have to be in the `Simulator` block.

For more details on the various simulator commands and functions, click [here](simulator.html).

A sample example displaying the simulator use can be seen on the
[Getting Started](gettingstarted.html#simulatingthehelloworldprogram) page.

### Functions

VIC&trade; provides a variety of in-built functions handling various aspects of
using an MCU such as writing to ports, selection of a port as digital or analog
input or output, reading from the A/D converter, debouncing a switch connected to a pin,
bit rotation, timers, delays and many more as described in the
[reference](functions.html).

Each function name is just followed by the suppported
arguments for that function. 

An argument can be anything from the MCU pin, MCU port register, strings,
numbers, hexadecimal numbers, expressions and blocks themselves.

### Operations

Six types of operations are supported on variables: arithmetic, assignment, bitwise, complement, logical and unary.
These are similar to the C language's arithmetic and logical operators.

- Arithmetic operators: `+`, `-`, `*`, `/`, `%`
- Assignment operators: `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `^=`, `|=`, `&=`, `<<=`, `>>=`
- Bitwise operators: `>>`, `<<`, `^`, `&`, `|`
- Complement operators: `!`, `~`
- Logical operators: `<`, `>`, `<=`, `>=`, `!=`, `==`, `&&`, `||`
- Increment/decrement operators: `++`, `--`

The precedence of these operators follows that of the C language.
@@NEXT@@ commandline.md @@PREV@@ gettingstarted.md
@@HIGHLIGHT@@
