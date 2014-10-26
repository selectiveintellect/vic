# VIC&trade; Syntax

Now that we have looked at some example code, let us describe more in detail the
various syntactical details of VIC&trade;.

VIC&trade; syntax is very much like Unix shell scripting with many similarities
and some notable differences.

A general VIC&trade; code file will have the following:

- [**PIC Header**](#picheader): This is a statement defining which PIC MCU the code is targeting
  by default. This enables the `vic` compiler to generate the correct target
assembly code.
- [**Pragmas**](#pragmas): These are statements that are specific to the code that the user
  is writing and informs the `vic` compiler how to optimize or select certain
traits for the assembly generation. For example, the user can specify a variable
to be 16-bits, and all computations with that variable will generate code doing
16-bit mathematics.
- [**Comments**](#comments): Comments are supported in VIC&trade; like any other
  scripting language.
- [**Blocks**](#blocks): All code that will run on the MCU will have to be enclosed in
  named blocks denoted by `{}`. There are many types of blocks supported:
    - [Main](#mainblock)
    - [Simulator](#simulatorblock)
    - [Loops](#loops)
    - [Actions](#actions)
    - [Interrupt Service Routines](#interruptserviceroutines)
    - [Conditional Blocks](#conditionalblocks)

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

Even though the PIC name is required, the `vic` compiler allows the user to
change the name of the PIC MCU on the commandline as well.

## Pragmas

## Comments

## Blocks

### Main Block

### Loops

### Actions

### Interrupt Service Routines

### Conditional Blocks

### Simulator Block

As simple as that. Each function name is just followed by the suppported
arguments for that function. Each block is just a name followed by a brace `{`
containing statements or function calls to pre-defined functions and ending by
another `}`. _TODO: improve this_

An argument can be anything from the MCU pin, MCU port register, strings,
numbers, hexadecimal numbers and blocks themselves.

@@NEXT@@ commandline.md @@PREV@@ gettingstarted.md
