# Using a Photoresistor

## Materials

- A PIC MCU with an ADC and an analog input
- Optional Low Pin Count Demo board from Microchip or Breadboard
- 1 x 1K Ohm resistor
- 1 x photoresistor such as SEN-09088 Mini Photocell from Sparkfun Electronics
- PICKit2 or PICKit3 programmer

## Setup

1. Breadboard power Vcc to 1K Ohm resistor
2. 1K Ohm resistor to Photoresistor Power pin
3. Photoresistor Ground pin to Breadboard ground
4. Wire between Photoresistor and 1K Ohm resistor to pin AN0 of PIC

    Vcc <---[R1]--->o<----[R2]---->Ground
                       |
                       V
                      AN0

If `R1` is the photoresistor and `R2` the 1K Ohm resistor, then the voltage will
increase with increasing light intensity.
If `R2` is the photoresistor and `R1` the 1K Ohm resistor, then the voltage will
decrease with increasing light intensity.

## C Code for Single Photoresistor

Reproduced here as a reference from
<http://www.hobbyprojects.com/microcontroller-tutorials/pic16f877a/photoresistor-input.html>

    //all these # below set up the PIC
    #include <16F877A.h>
    #device adc=8
    #FUSES NOWDT      //No Watch Dog Timer
    #FUSES HS         //Highspeed Osc > 4mhz
    #FUSES PUT        //Power Up Timer
    #FUSES NOPROTECT  //Code not protected from reading
    #FUSES NODEBUG    //No Debug mode for ICD
    #FUSES NOBROWNOUT //No brownout reset
    #FUSES NOLVP      //No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O
    #FUSES NOCPD      //No EE protection
    #use delay(clock=20000000) //crystal oscillator at 20000000 hertz
    #use rs232(baud=9600, xmit=PIN_C6, invert) //serial port output pin & baud rate

    //run photoresistor signal wire to pin AN0
    //connect LED/resistor to pin RB7

    void main(){
        int16 photo=0; //16 bit integer, safer than using int because
        //int is only 8 bit which might lead to overflow problems for add, multiply

        setup_adc(ADC_CLOCK_INTERNAL); //configure analog to digiral converter
        setup_adc_ports(ALL_ANALOG); //set pins AN0-AN7 to analog (can read values from 0-255 instead of just 0,1)
        while(true){ //loop forever
            set_adc_channel(0);//set the pic to read from AN0
            delay_us(20);//delay 20 microseconds to allow PIC to switch to analog channel 0
            photo=read_adc(); //read input from pin AN0: 0<=photo<=255

            //turn on LED when input > 127, else turn off LED
            //Put finger over photoresistor & take it off to see LED turn on/off
            //127 may not be the actual value that separates light from dark, so try
            //different values
            if(photo > 127){
                output_high(PIN_B7);
            }
            else{
                output_low(PIN_B7);
            }
        }
    }


## C Code for Multiple Photoresistors

Reproduced here as a reference from
<http://www.hobbyprojects.com/microcontroller-tutorials/pic16f877a/photoresistor-input.html>

    //all these # below set up the PIC
    #include <16F877A.h>
    #device adc=8
    #FUSES NOWDT       //No Watch Dog Timer
    #FUSES HS              //Highspeed Osc > 4mhz
    #FUSES PUT           //Power Up Timer
    #FUSES NOPROTECT //Code not protected from reading
    #FUSES NODEBUG //No Debug mode for ICD
    #FUSES NOBROWNOUT //No brownout reset
    #FUSES NOLVP      //No low voltage prgming, B3(PIC16) or B5(PIC18) used for I/O
    #FUSES NOCPD      //No EE protection
    #use delay(clock=20000000) //crystal oscillator at 20000000 hertz
    #use rs232(baud=9600, xmit=PIN_C6, invert) //serial port output pin & baud rate

    //read input from 3 photoresistors
    //run photoresistor signal wires to pin AN0, AN1, AN2

    void main(){
        int16 photo0=0; //16 bit integer, safer than using int
        //int is only 8 bit which might lead to overflow problems for add, multiply
        int16 photo1=0;
        int16 photo2=0;

        setup_adc(ADC_CLOCK_INTERNAL); //configure analog to digiral converter
        setup_adc_ports(ALL_ANALOG); //set pins AN0-AN7 to analog (can read values from 0-255 instead of just 0,1)

        while(true){ //loop forever
            set_adc_channel(0);//set the pic to read from AN0
            delay_us(20);//delay 20 microseconds to allow PIC to switch to analog channel 0
            photo0=read_adc(); //read input from pin AN0: 0<=photo<=255

            set_adc_channel(1);//set the pic to read from AN1
            delay_us(20);
            photo1=read_adc();

            set_adc_channel(2); //set the pic to read from AN2
            delay_us(20);
            photo2 = read_adc();

            //You could add 3 LEDs and turn them on if photo0/1/2 > 127
            //just as with code for single photoresistor
        }
    }

