#UART Example

Reference code from
<http://www.hobbyprojects.com/microcontroller-tutorials/pic16f877a/output-messages-to-computer-screen.html>.

## C code for printing to screen using UART

    #include <16F877A.h>
    #device adc=8
    #FUSES NOWDT //No Watch Dog Timer
    #FUSES HS //Highspeed Osc > 4mhz
    #FUSES PUT //Power Up Timer
    #FUSES NOPROTECT //Code not protected from reading
    #FUSES NODEBUG //No Debug mode for ICD
    #FUSES NOBROWNOUT //No brownout reset
    #FUSES NOLVP //No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O
    #FUSES NOCPD //No EE protection
    #use delay(clock=20000000) // Sets crystal oscillator at 20 megahertz
    #use rs232(baud=9600, xmit=PIN_C6, invert) //Sets up serial port output pin & baud rate

    void main(){
        int x = 0;
        while(true){
            x = x + 1;
            /*
             * This is an ordinary C language printf statement that will display on
             * the screen of your PC.
             * But, you need to open a special program to read serial port input,
             * like HyperTerminal.
             * Make sure the baud rate of the program matches this code’s baud rate
             * (9600 bits / second)
             */
            printf("hello, x=%d\r\n",x); //send this text to serial port
            delay_ms(100); //wait 100 milliseconds
        }
    }
