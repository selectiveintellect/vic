#Installation

There are two easy ways to install VIC. One is using CPAN and the other is
from source.

## Pre-requisites

You will need an operating system that supports Perl, such as Linux&reg;,
FreeBSD, OpenBSD and Apple&reg; Mac OS X.

For Microsoft Windows&reg;, you can download [Strawberry
Perl](http://www.strawberryperl.com).

The minimum version of Perl required is 5.10.1.

You will also need `git` installed if you're downloading the code from
[Github](https://github.com/selectiveintellect/vic).

## Supporting Applications

To make full use of VIC&trade; you need to install the following applications as
well:

- [gputils](http://gputils.sourceforge.net) for compiling VIC&trade; output
- [gpsim](http://gpsim.sourceforge.net/gpsim.html) for default simulator support
- [Piklab](http://piklab.sourceforge.net/) as an IDE
- [pk2cmd](pk2cmd.html) for command-line programming of the device, if using the [PICKit 2 Starter Kit](http://www.microchip.com/pickit2/)
- [gtkwave](http://gtkwave.sourceforge.net/) for viewing simulator output
  waveforms.

##Installing from CPAN

This is the simplest way to install the release versions of VIC into
`/usr/local` of your Unix-like system.

    $ sudo cpan -i VIC

On Microsoft Windows&reg;, you can install using the below command from the
Strawberry Perl command shell.

    > cpan -i VIC

Another way to install from CPAN is to use `App::cpanminus`, which may be
available on your operating system or you could install that as well using the
cpan client.

    > cpan -i App::cpanminus
    > cpanm VIC

##Building from source

Download the software from Github.

    $ git clone https://github.com/selectiveintellect/vic.git
    $ cd vic
    $ perl ./Build.PL --install_base=/usr/local/
    $ ./Build test
    $ sudo ./Build install

You may need to install the Perl package dependencies first which are done as
below:

    $ sudo cpan -i Pegex App::Prove

or using `App::cpanminus`

    $ cpanm App::Prove
    $ cpanm Pegex

##Dependencies

This module depends on the following:

- `Module::Build` (this is needed for building)
- `Pegex` (this is needed for grammar parsing. Needs to be installed from CPAN)
- `Getopt::Long` (for handling command line options. Comes with perl itself)
- `XXX` (only required for debugging)

##Testing the Module (Developers Only)

To test you will need to have `App::Prove` installed if you're developing the
software

    $ prove -lv t

Another option is to use `Build.PL`

    $ ./Build test

##Vim Syntax Highlighting

The installation provides syntax highlighting for the [Vim](http://www.vim.org)
editor.

The syntax for VIC is available in the file `share/vic.vim` in the source
repository or in the `share` directory of the installation. You can place it in
`$HOME/.vim/syntax` on Linux, FreeBSD, OpenBSD and OS X, and in `$HOME/vimfiles/syntax` on Windows
systems.


##Compiling examples

The examples are in `share/examples` folder. To compile the `helloworld.vic`
example you can do the following:

    $ ./bin/vic ./share/examples/helloworld.vic -o ./share/examples/helloworld.asm

This will generate the PIC&reg; assembly for the VIC file.

##Placing `vic` in your `$PATH` for Makefiles

If you are installing VIC in a local directory, you may need to set it in the
`$PATH` variable for your system.

##Testing on PIC microcontrollers on Linux and Mac OS X

The `helloworld.vic` test is for the Low Pin Count Demo board from Microchip and
uses the [PICKit 2 Starter Kit](http://www.microchip.com/pickit2/) programmer
to write to the microcontroller P16F690 on the board.

You will need to have `gputils` and `gpsim` packages installed on Linux or Mac OS X.

For Mac OS X, you may need to use MacPorts to easily install the `gputils` and `gpsim` packages.

    $ cd share/examples/
    $ gpasm -pP16F690 -M -c helloworld.asm -o helloworld.o
    $ gplink -q -o helloworld.hex helloworld.o

This will produce a `helloworld.hex` file which you will have to write to the
microcontroller using PICKit2 programmer from Microchip. You could use any other
programmer as well as long as you have the right software for it. To write to
the microcontroller on Linux or Mac OS X you need to have `pk2cmd` installed, as
mentioned [here](pk2cmd.html).

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

##Testing on PIC microcontrollers on Windows

For Windows, we currently recommend using the Microchip provided IDE. You can
use VIC to generate the assembly files which you can then load into the IDE as
part of your project and use.

You may choose to use [Piklab](http://piklab.sourceforge.net/) as your IDE
instead.

If you want to use Cygwin to perform builds using `gpasm` and `pk2cmd` you may
do that and let us know if you succeed so we can write instructions for other
users.

##Recompiling the grammar

This is for VIC developers only.

To recompile the grammar into `lib/VIC/Grammar.pm` run,

    $ ./share/rebuild-grammar

or

    $ ./share/rebuild-grammar.PL

or

    $ perl ./Build.PL
    $ ./Build

All of the above do the same thing.

@@NEXT@@ hardware.md @@PREV@@ inception.md
