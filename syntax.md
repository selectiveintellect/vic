# VIC&trade; Syntax

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

@@NEXT@@ simulator.md @@PREV@@ gettingstarted.md
