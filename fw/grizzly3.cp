#line 1 "E:/Grizzly3/fw/grizzly3.c"
#line 1 "e:/grizzly3/fw/grizzly3.h"
#line 1 "c:/programmi/mikroelektronika/mikroc pro for pic/include/built_in.h"
#line 59 "e:/grizzly3/fw/grizzly3.h"
const unsigned PPM_map[] = {0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 20};
#line 13 "E:/Grizzly3/fw/grizzly3.c"
sbit P2 at GP0_bit;
sbit P1 at GP1_bit;
sbit JP at GP2_bit;
sbit PPM at GP3_bit;
sbit N2 at GP4_bit;
sbit N1 at GP5_bit;


unsigned char PPM_level = 0;
unsigned char PPM_pulse = 0;
unsigned char PPM_value = 0;

unsigned char PWM_i = 0;
unsigned char PWM_semiperiod = 0;
unsigned char PWM_value = 0;
unsigned char PWM_command = 0;
unsigned char PWM_direction =  2 ;
unsigned char PWM_last_direction =  1 ;
unsigned char PWM_brake = 0;

unsigned char i;
unsigned int j;

void interrupt()
{
 if(GPIF_bit)
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

 if(T1IF_bit)
 {
 TMR1H = 255;

 if(++PWM_i ==  20 )
 {
 PWM_i = 0;

 if(PWM_value > PWM_command)
 PWM_value--;
 else if(PWM_value < PWM_command)
 PWM_value++;
 }

 if(PWM_brake)
 GPIO =  0b00110000 ;
 else if(PWM_value > PWM_i)
 {
 if(PWM_direction ==  0 )
 GPIO =  0b00100001 ;
 else if(PWM_direction ==  1 )
 GPIO =  0b00010010 ;
 }
 else
 GPIO =  0b00000000 ;

 T1IF_bit = 0;
 }
}

void syncPPM()
{

 i = 0;
 while(i <  50 )
 {
 PPM_pulse = 0;
 while(!PPM_pulse);

 if(PPM_pulse <  56  || PPM_pulse >  131 )
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

 while(PPM_pulse <  94  - 3  || PPM_pulse >  94  + 3 );

 while(1)
 {

 if(PPM_pulse >  56 )
 {
 PPM_value = PPM_pulse;
 if(PPM_value >  125 )
 PPM_value =  125 ;
 if(PPM_value <  63 )
 PPM_value =  63 ;


 if(PPM_value >  94  + 3 )
 {

 if(PWM_direction ==  0 )
 PWM_command = PPM_map[PPM_value -  94 ];
 else
 {
 PWM_command = 0;
 if(!PWM_value)
 {
 PWM_brake = 0;
 PWM_direction =  0 ;
 }
 }
 }
 else if(PPM_value <  94  - 3 )
 {

 if(PWM_direction ==  1 )
 PWM_command = PPM_map[ 94  - PPM_value];
 else
 {
 PWM_command = 0;
 if(!PWM_value)
 {
 PWM_brake = 0;
 PWM_direction =  1 ;
 }
 }
 }
 else
 {

 if(PWM_value)
 PWM_command = 0;
 else
 PWM_brake = 1;

 PWM_direction =  2 ;
 }

 PPM_pulse = 0;
 }
 }
}

void grizzly3_2POS()
{

 while(PPM_pulse >  63  + 3  + 3 );

 while(1)
 {

 if(PPM_pulse >  56 )
 {
 PPM_value = PPM_pulse;
 if(PPM_value >  125 )
 PPM_value =  125 ;
 if(PPM_value <  63 )
 PPM_value =  63 ;


 if(PPM_value >  63  + 3  + 3 )
 {

 if(PWM_direction ==  0  || pwm_direction ==  1 )
 PWM_command = PPM_map[(PPM_value -  63 ) / 2];
 else
 {
 PWM_command = 0;
 if(!PWM_value)
 {
 PWM_brake = 0;
 if(PWM_last_direction ==  1 )
 PWM_direction =  0 ;
 else
 PWM_direction =  1 ;

 PWM_last_direction = PWM_direction;
 }
 }
 }
 else
 {

 if(PWM_value)
 PWM_command = 0;
 else
 PWM_brake = 1;

 PWM_direction =  2 ;
 }

 PPM_pulse = 0;
 }
 }
}

void main() {

 asm {
 bsf STATUS, RP0
 call 0x03ff
 movwf OSCCAL
 bcf STATUS, RP0
 }

 OPTION_REG = 0b00000011;
 WPU = 0b00000100;

 GPIO =  0b00000000 ;


 TRISIO = 0b11001100;

 GIE_bit = 1;
 PEIE_bit = 1;
 GPIE_bit = 1;
 IOC = 0b00001000;
 T1IF_bit = 0;
 T1IE_bit = 1;
 T1CON = 0b00000001;


 syncPPM();


 PWM_brake = 1;

 if(JP)
 grizzly3_3POS();
 else
 grizzly3_2POS();
}
