#The Philosophy of VIC&trade;

VIC&trade; originated from finding difficulty in writing generic code that
would run on any micro-controller of [Microchip's](http://www.microchip.com) 
PIC&reg; family that were similar in nature,
such as any PIC&reg; of the PIC12, PIC16 family or the PIC18 family.

There were various options such as using C or PICBASIC&trade; with [Microchip's compilers](http://www.microchip.com/compilers/) or
using [Just Another Language (JAL)](http://justanotherlanguage.org/) which is an interesting high level language
that also helps users to program PIC&reg; microcontrollers with ease and
provides a variety of libraries.

However, the JAL syntax did not seem interesting since it was based off of
Pascal. Their simulator webpage links also did not work. Using Microchip's PICBASIC&trade;
was equally as _cumbersome_ as using their C compiler, which did not allow for
ease of understanding of the code after a period of time. With increasing
complexity of code, these options started to seem less and less desirable.
Every time a new project was to be done, we ended up having to copy-paste code
for various common things and obviously, that led to various unforeseen errors
and sometimes having to rewrite everything from scratch every time. We did start
to write functions and libraries of our own, but in the end we decided that
auto-generation of code was more desirable for long term maintenance of our
projects.

This is one of the main reasons of the desire to use a domain
specific language such as VIC&trade; which would make it easy for the developer to
write code representing the [Do What I Mean
(DWIM)](https://en.wikipedia.org/wiki/DWIM) philosophy and allowing for
code re-use without having to deal with issues arising from copy-pasting code
from earlier projects. The other necessity was that if we wanted to swap out one
microcontroller for another, we should not have to read the data sheet and make
sure that the code would work, or have to make changes to register names for the
code to be usable. We just wanted the compiler to do this for us. Hence, today
VIC&trade; does that for you. VIC&trade; also would then allow for custom optimizations
to be made for specific microcontrollers that would not be needed for the generic cases.

Moreover, there was a requirement to write code in such a way such that it would
be less procedural and more event or action based, where certain functions would invoke
certain actions if needed. This would enable clarity for the programmer and QA
tester who would be verifying the code and creating test benches to verify
outputs.

Another requirement was to make the code very easy to debug, which is why
VIC&trade; generates valid assembly code which can work in any existing PIC&reg; debugger such
as that from Microchip or something open source like
[Piklab](http://piklab.sourceforge.net/).

We also wanted to have an easy way to generate boiler plate code. In various
scenarios, you would want boiler plate code generated and then modified slightly
for different applications. This boiler plate code would be generated using
pre-processor macros which were quite irritating to use and create, especially
if you wanted to use the same boiler plate code for different microcontrollers,
you would have to write these macros for each microcontroller. VIC&trade; would
automate this where you would write the boilerplate code once, and the compiler
would generate the appropriate code for the microcontroller specified. This
would generate assembly to which further modification could take place by the
experienced developer for specific cases where assembly programming would be
necessary.

VIC&trade; would also have a way to integrate with existing PIC&reg; simulators
like [GNU PIC simulator](http://gpsim.sourceforge.net/gpsim.html) `gpsim`, and integrates with the
[GNU PIC assembler](http://gputils.sourceforge.net/) `gpasm`.

In addition to all of this, having to read data sheets for each microcontroller
in detail to implement standard features like debouncing inputs, ADC operation,
USART/SPI/I2C serial bus implementation could be completely avoided if
VIC&trade; provided these out of the box.

Last but not the least, VIC&trade; would have a method to perform formal verification
of the code. This would be the killer feature needed for those performing
microcontroller programming for devices that are mission critical and need to
have a high reliability rating such as in the fields of medicine and aerospace.
However, this feature has **not** been implemented yet.

## Development Style

VIC&trade;'s development style is a mixture of procedural and event-based. Certain
instructions such as timers, debouncers have event-based _actions_ that get
invoked when the conditions are met. This allows for the programmer to implement
Perl or Javascript like event callbacks for such tasks.

@@NEXT@@ faq.md @@PREV@@ index.md

