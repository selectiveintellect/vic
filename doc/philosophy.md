The Philosophy of VIC
======================

VIC came about as a result of finding difficulty in writing generic code that
would run on any micro-controller of the PIC family that were similar in nature,
such as any PIC of the PIC12XXXX PIC16XXXX family or the PIC18XXXX family.

There were various options such as using C with Microchip's compilers or
using JAL which is a high level language in itself.

However, debugging JAL was not easy and using C was no different from using
PIC assembly as it did not help much in being generic enough.

As the code got more and more complex, it became less and less obvious to the
naked eye. This is one of the main reasons of the evolution to use a domain
specific language such as VIC which would make it easy for the developer to
write code representing the Do What I Mean (DWIM) philosophy.

Another requirement was to make the code very easy to debug, which is why VIC
generates valid assembly code which can work in any existing PIC debugger such
as that from Microchip or something open source like Piklab.

Following this, boiler-plate code generation was also a requirement. Many times
you would want to perform minor additions to existing code bases and having to
add various pre-processing macros to existing assembly code bases created lots
of confusion and difficulties. VIC would allow creating a boiler plate code that
would generate assembly to which further modification could take place by the
developer for specific cases.

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

