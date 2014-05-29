VIC
===

VIC is a nice syntax that compiles to PIC assembly.

![MeMe](https://raw.githubusercontent.com/vikasnkumar/vic/master/doc/images/vicmeme.jpg)

#Building as a user

    $ perl ./Build.PL --install_base=/usr/local/
    $ ./Build test
    $ ./Build install

#Dependencies

This module depends on the following:

- `Module::Build` (this is needed for building)
- `Pegex` (this is included as a subrepo `ext/pegex-pm`)
- `Getopt::Long` (for handling command line options. Comes with perl itself)
- `XXX` (only required for debugging)

#Testing the Module

To test you will need to have `App::Prove` installed if you're developing

    $ prove -lv t

Another option is to use `Build.PL`

    $ ./Build test

#Vim Syntax

The `vim` syntax for VIC is in `share/vic.vim`. You can place it in
`$HOME/.vim/syntax` on Linux and OS X and in `$HOME/vimfiles/syntax` on Windows
systems.

#How to write VIC programs

Documentation coming soon...


#Compiling examples

The examples are in `share/examples` folder. To compile the `helloworld.vic`
example you can do the following:

    $ ./bin/vic ./share/examples/helloworld.vic -o ./share/examples/helloworld.asm

This will generate the PIC assembly for the VIC file.

#Placing `vic` in your `$PATH` for Makefiles

Let us assume that your git checkout copy is in `$HOME/github/vic` then,

    $ export VICPATH=$HOME/github/vic
    $ export PERL5LIB=${VICPATH}/lib:${VICPATH}/pegex-pm/lib:$PERL5LIB
    $ export PATH=${VICPATH}/bin:$PATH
    $ which vic

_If you're installing it from CPAN or using `Build.PL` you do not need to set the
above._

#Testing on PIC microcontrollers on Linux and Mac OS X

The `helloworld.vic` test is for the Low Pin Count Demo board from Microchip and
uses the PICKit2 programmer to write to the microcontroller P16F690 on the
board.

You will need to have `gputils` installed on Linux or Mac OS X. (Have not
experimented on Windows.)

    $ cd share/examples/
    $ gpasm -pP16F690 -M -c helloworld.asm -o helloworld.o
    $ gplink -q -o helloworld.hex helloworld.o

This will produce a `helloworld.hex` file which you will have to write to the
microcontroller using PICKit2 programmer from Microchip. You could use any other
programmer as well as long as you have the right software for it. To write to
the microcontroller on Linux or Mac OS X you need to have `pk2cmd` installed.

If you have `pk2cmd` installed in `/usr/local` you will need to set the `PATH`
variable as follows before doing the write to the microcontroller:

    $ export PATH=${PATH}:/usr/local/bin:/usr/share/pk2

Before you run `pk2cmd` on Mac OS X, you will need to set the `lsusb` command
which is available on Linux but not on the Mac but is used by `pk2cmd`
internally.

    $ alias lsusb="system_profiler SPUSBDataType"

To write to the microcontroller run the following:

    $ pk2cmd -PP16F690 -M -Fhelloworld.hex

To run the test and have the microcontroller execute the code on the Low Pin
Count Demo board to turn on the LED,

    $ pk2cmd -PP16F690 -T

To stop the test and turn off the LED,

    $ pk2cmd -PP16F690

To erase the code from the microcontroller,

    $ pk2cmd -PP16F690 -E

*NOTE*: All the above have been implemented in a `GNUmakefile` present under
`share/examples/GNUmakefile`.

#Testing on PIC microcontrollers on Windows

For Windows, we currently recommend using the Microchip provided IDE. You can
use VIC to generate the assembly files which you can then load into the IDE as
part of your project and use.

If you want to use Cygwin to perform builds using `gpasm` and `pk2cmd` you may
do that and let us know if you succeed so we can write instructions for other
users.


#Recompiling the grammar

This is for VIC developers only.

To recompile the grammar into `lib/VIC/Grammar.pm` run,

    $ ./share/rebuild-grammar

or

    $ ./share/rebuild-grammar.PL

or

    $ perl ./Build.PL
    $ ./Build

All of the above do the same thing.

#Contributors

- Vikas N Kumar [@vikasnkumar](https://github.com/vikasnkumar/)
- Ingy [@ingydotnet](https://github.com/ingydotnet/)

#Copyright

Copyright: 2014. Vikas N Kumar. All Rights Reserved.

LICENSE: refer LICENSE file in the repository.


