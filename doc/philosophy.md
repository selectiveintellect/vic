The Philosophy of VIC
======================

VIC came about as a result of finding difficulty in writing generic code that
would run on any micro-controller of the PIC family that were similar in nature,
such as any PIC of the PIC12XXXX PIC16XXXX family or the PIC18XXXX family.

There were various options such as using C or PICBasic with Microchip's compilers or
using JAL which is an interesting high level language in itself.

However, writing JAL code didn't seem like fun due to its similarities to Pascal
and using Microchip's PICBasic was equally as _difficult_ as using C.
As the code got more and more complex, it became less and less obvious to read
and understand. Every time a new project was started, copy-pasting old code was
necessary to use features that were once already coded up. This led to various
errors and sometimes rewriting of the whole code itself.

This is one of the main reasons of the evolution to use a domain
specific language such as VIC which would make it easy for the developer to
write code representing the Do What I Mean (DWIM) philosophy and allowing for
code re-use without having to deal with issues arising from copy-pasting code
from earlier projects.

Moreover, there was a requirement to write code in such a way such that it would
be less procedural and more event based, where certain functions would invoke
certain actions if needed. This would enable clarity for the programmer and QA
tester who would be verifying the code and creating test benches to verify
outputs.
Another requirement was to make the code very easy to debug, which is why VIC
generates valid assembly code which can work in any existing PIC debugger such
as that from Microchip or something open source like Piklab.

Following this, boiler-plate code generation was also a requirement. Many times
you would want to perform minor additions to existing code bases and having to
add various pre-processing macros to existing assembly code bases created lots
of confusion and difficulties. VIC would allow creating a boiler plate code that
would generate assembly to which further modification could take place by the
developer for specific cases.

Last but not the least, VIC would have a method to perform formal verification
of the code. This would be the killer feature needed for those performing
microcontroller programming for devices that are mission critical and need to
have a high reliability rating such as in the fields of medicine, aerospace etc.

VIC also would then allow for custom optimizations to be made for specific
microcontrollers that would not be needed for the generic cases.

In addition to all of this, having to read data sheets for each microcontroller
in detail to implement standard features like debouncing inputs, ADC operation,
USART/SPI/I2C serial bus implementation could be completely avoided if VIC
provided these out of the box.

# Event-based Development

VIC's development style is a mixture of procedural and event-based. Certain
instructions such as timers, debouncers have event-based _actions_ that get
invoked when the conditions are met. This allows for the programmer to implement
Perl/Javascript like events for such tasks.

