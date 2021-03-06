#Tasks To Accomplish

## Language Features

- Indirect addressing or pointer addressing - DONE for strings
- Optimize memory usage and detect availability of RAM, Page faults etc.
- Parameter passing in Action/ISR blocks
- User-defined blocks/functions

        MyFunc {
            $pin = shift;
            return $result;
        }
        Main {
            $value = MyFunc RC0;
        }

- Data flow analysis for reusing existing scratch memory space
- Improve error messages (each AST node can be tagged with a line number)

## Code Generation Features

- String tables (read-only data) - DONE for UART
- String buffers for writing - DONE with auto-allocation of fixed size and of a
  configurable using pragma size of 32 bytes for empty string

    $value = "";
    read UART0, Action {
        $value .= shift; ## CONCAT operator done for single bytes only
    };

    - concatenation of strings needs more work
    - array access of string bytes
    - printing to UART of string only till the index not the full length
    - not all strings have indexes but should

- ASCII conversion of numbers and alphabets - DONE for UART
- Sleep/Wake-up of processor
    - DONE using Interrupt-on-change
    - DONE using WDT (only for PIC16F690)
- EEPROM read/write and storage of large data blobs such as music files or
  images
- Verify PWM implementation on Oscilloscope - (example is verified)
- UART: need to do interrupt-based read/write -  DONE READ

    # does this store the incoming bytes in a buffer ?
    read UART0, $value; # a single byte
    read UART0, Action/ISR {
        $value = shift; # a single byte
    };

- I2C
- SPI
- USB
- Ethernet
- Watchdog Timer - DONE for PIC16F690
- Power management
- Interrupt on Change for reads (Event based reading) - DONE for P16F690

        read RC0, Action/ISR {
            $value = shift;
        };

- Code protection features if allowed by chip
- Oscillator selection and modification
- Usage of Comparators with examples
- In-Circuit Serial Programming example
- 16-bit arithmetic
- fixed-point arithmetic

## FIXME

- P18F13K50 code generation has bugs

## Examples

- XOR encoding of data
- Running a Motor using VIC and PWM capabilities
- Exchanging data with a desktop OS using UART
- Extracting firmware from monitor VGA cable using I2C
- An example of reading data from SPI bus
- An example of building a low speed USB device
- An example of a 10-BaseT Ethernet
- Examples for power management, sleep/wake-up features
- Examples for all other chip features like:
    - Comparators
    - 16-bit Timers
    - Oscillators
    - EEPROM read/write/storage

## Tutorials and Usability

1. Tutorial on blinking LEDs, rotating them etc.
2. Tutorial on using simulator
3. Tutorial on using one and two 7-segment displays, demonstrating multiplexing
4. Tutorial on motor control
5. Tutorial on debugging with Oscilloscopes
6. Tutorial on debugging with Logic Analyzers
7. Tutorial on playing audio with EEPROM stored WAV file


