/*  Grizzly 3 Winch Controller
    2017 tHeo

    Changelog:
    29/04/17 > Porting dal firmware uESC
    
*/

#include "grizzly3.h"

// CONFIGURAZIONE PIN

sbit P2 at GP0_bit;
sbit P1 at GP1_bit;
sbit JP at GP2_bit;
sbit PPM at GP3_bit;
sbit N2 at GP4_bit;
sbit N1 at GP5_bit;

// VARIABILI
unsigned char PPM_level = 0;
unsigned char PPM_pulse = 0;
unsigned char PPM_value = 0;

unsigned char PWM_i = 0;
unsigned char PWM_semiperiod = 0;
unsigned char PWM_value = 0;
unsigned char PWM_command = 0;
unsigned char PWM_direction = PWM_IDLE;
unsigned char PWM_last_direction = PWM_REVERSE;
unsigned char PWM_brake = 0;

unsigned char i;
unsigned int j;

void interrupt()
{
    if(GPIF_bit) // Lettura comandi PPM
    {
        if(PPM && !PPM_level)
        {
            TMR0 = 0;
            PPM_level = 1;
        }
        else if(!PPM && PPM_level)
        {
            PPM_pulse = TMR0;
            PPM_level = 0;
        }

        GPIF_bit = 0;
    }

    if(T1IF_bit) // Gestione PWM
    {
        TMR1H = 255; // Precarico Timer1
        // Step PWM
        if(++PWM_i == PWM_MAX)
        {
            PWM_i = 0;

            if(PWM_value > PWM_command)
                PWM_value--;
            else if(PWM_value < PWM_command)
                PWM_value++;
        }

        if(PWM_brake)
            GPIO = GPIO_BRK;
        else if(PWM_value > PWM_i)
        {
            if(PWM_direction == PWM_FORWARD)
                GPIO = GPIO_FWD;
            else if(PWM_direction == PWM_REVERSE)
                GPIO = GPIO_REV;
        }
        else
            GPIO = GPIO_OFF;

        T1IF_bit = 0;
    }
}

void syncPPM()
{
    // Attendo segnale PPM valido
    i = 0;
    while(i < STARTUP_PPM_FRAMES)
    {
        PPM_pulse = 0;
        while(!PPM_pulse);

        if(PPM_pulse < PPM_900_US || PPM_pulse > PPM_2100_US)
            i = 0;
        else
            i++;
    }
}

void beep(unsigned int duration)
{
    for(j = 0; j < duration; j++)
    {
        P1 = 1;
        N2 = 1;

        Delay_us(500);

        N1 = 0;
        N2 = 0;
        P1 = 0;
        P2 = 0;

        Delay_us(250);

        N1 = 1;
        P2 = 1;

        Delay_us(500);

        N1 = 0;
        N2 = 0;
        P1 = 0;
        P2 = 0;

        Delay_us(250);
    }
}

void grizzly3_3POS()
{
    // Attendo che il comando sia nella posizione "verricello fermo"
    while(PPM_pulse < PPM_ZERO_LO || PPM_pulse > PPM_ZERO_HI);
    
    while(1)
    {
        // Lettura comando gas
        if(PPM_pulse > PPM_900_US)
        {
            PPM_value = PPM_pulse;
            if(PPM_value > PPM_2000_US)
                PPM_value = PPM_2000_US;
            if(PPM_value < PPM_1000_US)
                PPM_value = PPM_1000_US;

            // Elaboro segnale ricevuto
            if(PPM_value > PPM_ZERO_HI)
            {
                // AVANTI
                if(PWM_direction == PWM_FORWARD) // Sono già in avanti
                    PWM_command = PPM_map[PPM_value - PPM_1500_US]; // PWM
                else
                {
                    PWM_command = 0; // Comando 0
                    if(!PWM_value) // Motore fermo, posso invertire la rotazione
                    {
                        PWM_brake = 0;
                        PWM_direction = PWM_FORWARD;
                    }
                }
            }
            else if(PPM_value < PPM_ZERO_LO)
            {
                // INDIETRO
                if(PWM_direction == PWM_REVERSE) // Già indietro
                    PWM_command = PPM_map[PPM_1500_US - PPM_value]; // PWM
                else
                {
                    PWM_command = 0; // Comando 0
                    if(!PWM_value) // Motore fermo, posso invertire la rotazione
                    {
                        PWM_brake = 0;
                        PWM_direction = PWM_REVERSE;
                    }
                }
            }
            else
            {
                // FERMO
                if(PWM_value) // Motore ancora in movimento
                    PWM_command = 0; // Comando 0
                else
                    PWM_brake = 1; // Freno il verricello

                PWM_direction = PWM_IDLE;
            }

            PPM_pulse = 0; // Resetto valore
        }
    }
}

void grizzly3_2POS()
{
    // Attendo che il comando sia nella posizione "verricello fermo"
    while(PPM_pulse > PPM_STOP);
    
    while(1)
    {
        // Lettura comando gas
        if(PPM_pulse > PPM_900_US)
        {
            PPM_value = PPM_pulse;
            if(PPM_value > PPM_2000_US)
                PPM_value = PPM_2000_US;
            if(PPM_value < PPM_1000_US)
                PPM_value = PPM_1000_US;

            // Elaboro segnale ricevuto
            if(PPM_value > PPM_STOP)
            {
                // VERRICELLO ACCESO
                if(PWM_direction == PWM_FORWARD || pwm_direction == PWM_REVERSE) // Sono già in avanti
                    PWM_command = PPM_map[(PPM_value - PPM_1000_US) / 2]; // PWM
                else
                {
                    PWM_command = 0; // Comando 0
                    if(!PWM_value) // Motore fermo, posso invertire la rotazione
                    {
                        PWM_brake = 0;
                        if(PWM_last_direction == PWM_REVERSE)
                            PWM_direction = PWM_FORWARD;
                        else
                            PWM_direction = PWM_REVERSE;
                            
                        PWM_last_direction = PWM_direction;
                    }
                }
            }
            else
            {
                // FERMO
                if(PWM_value) // Motore ancora in movimento
                    PWM_command = 0; // Comando 0
                else
                    PWM_brake = 1; // Freno il verricello

                PWM_direction = PWM_IDLE;
            }

            PPM_pulse = 0; // Resetto valore
        }
    }
}

void main() {
    // INIZIALIZZAZIONE HARDWARE
    asm {
         bsf STATUS, RP0
         call 0x03ff
         movwf OSCCAL
         bcf STATUS, RP0
     }                          // Calibrazione oscillatore interno

    OPTION_REG = 0b00000011;    // Timer0 con prescaler 1/16 (ciclo 4,096 msec), pull-up abilitati
    WPU = 0b00000100;           // Pull-up abilitato su GP2 (JP)

    GPIO = GPIO_OFF;            // Transistor spenti
    
             //xx543210
    TRISIO = 0b11001100;        // Configuro input/output

    GIE_bit = 1;                // Interrupt abilitati
    PEIE_bit = 1;               // Interrupt periferiche abilitati
    GPIE_bit = 1;               // Interrupt-On-Change abilitato
    IOC = 0b00001000;           // IOC abilitato su GP3 (PPM)
    T1IF_bit = 0;
    T1IE_bit = 1;               // Interrupt Timer1 abilitato
    T1CON = 0b00000001;         // Timer1 con prescaler 1/1

    // Attendo segnale
    syncPPM();

    // Attivo dragbrake
    PWM_brake = 1;

    if(JP) // Lettura jumper
        grizzly3_3POS();
    else
        grizzly3_2POS();
}