Code: // PIC16F877A Configuration Bit Settings
// 'C' source line config statements
// CONFIG

#pragma config FOSC = HS     // Oscillator Selection bits (RC oscillator)
#pragma config WDTE = OFF        // Watchdog Timer Enable bit (WDT enabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config BOREN = OFF       // Brown-out Reset Enable bit (BOR enabled)
#pragma config LVP = OFF         // Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3/PGM pin has PGM function; low-voltage programming enabled)
#pragma config CPD = OFF        // Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
#pragma config WRT = OFF        // Flash Program Memory Write Enable bits (Write protection off; all program memory may be written to by EECON control)
#pragma config CP = OFF         // Flash Program Memory Code Protection bit (Code protection off)

// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#define _XTAL_FREQ 4000000
#define FAN1 PORTDbits.RD6
#define FAN2 PORTDbits.RD5
#define FAN3 PORTDbits.RD7
#define ON 1
#define OFF 0

void main (void){
    TRISDbits.TRISD6=0;   //PB0 PB1 PB2 output
    TRISDbits.TRISD5=0;
    TRISDbits.TRISD7=0;
    TRISAbits.TRISA0=1; //input for analog channel
    TRISB=0x00; // for 7-segment 1
    TRISC=0x00; // for 7 segment 2
    ADCON0=0x81;
    ADCON1=0xCE;
    while (1){
        __delay_ms (1); //ADC to sample
        ADCON0bits.GO=1;
        while (ADCON0bits.GO==1);
        unsigned int Sensor=ADRESL+(ADRESH<<8);;
        unsigned int Temperature= Sensor*(.448);
        unsigned int num1;
        unsigned int num2;
        num2=Temperature%10;
        num1=Temperature/10;
        unsigned int arr []={0xFC, 0x60, 0xDA, 0xF2, 0x66, 0xB6, 0xBE, 0xE0, 0xFE, 0xF6, 0xEE, 0x3E, 0x9C, 0x7A, 0x9E, 0x8E};
       
        PORTB= arr [num1];
        PORTC= arr [num2];
        __delay_ms (250);
            // temp less than 20 celsius
            if (Temperature<=24){
                FAN1=ON;
                FAN2=OFF;
                FAN3=OFF;
            }
            // temp less than 25 celsuis
            else if (Temperature>24 && Temperature<=25){
                FAN1=ON;
                FAN2=ON;
                FAN3=OFF;
            }
            // temp greater than 25 celsius
            else if (Temperature>25){
                FAN1=ON;
                FAN2=ON;
                FAN3=ON;
            }
        }            
}

