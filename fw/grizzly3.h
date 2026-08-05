/*  Grizzly 3 Winch Controller
    2017 tHeo

    Fosc = 4.000.000 Hz
    Fclk = 1.000.000 Hz
    
    Timer0: 1.000.000 / 256 / 16 (prescaler) = 4,096 ms (ciclo) lettura PPM
    Timer2: 1.000.000 / 256 /  8 (prescaler) = 488 Hz PWM

              -----u-----
        VDD -|o          |- GND
         N1 -|GP5     GP0|- P2
         N2 -|GP4/AN3 GP1|- P1
        PPM -|GP3     GP2|- !2POS
              -----------
*/

#include "built_in.h"

#define PPM_900_US 56     // -110%
#define PPM_1000_US 63    // -100%
#define PPM_1166_US 73    // - 67%
#define PPM_1200_US 75    // - 75%
#define PPM_1250_US 78    // - 50%
#define PPM_1333_US 83    // - 33%
#define PPM_1400_US 88    // - 25%
#define PPM_1500_US 94    //    0%
#define PPM_1600_US 100   // + 25%
#define PPM_1666_US 104   // + 33%
#define PPM_1750_US 109   // + 50%
#define PPM_1800_US 113   // + 66%
#define PPM_1833_US 115   // + 75%
#define PPM_2000_US 125   // +100%
#define PPM_2100_US 131   // +110%

#define PPM_DEADBAND 3
#define PPM_ZERO_LO PPM_1500_US - PPM_DEADBAND
#define PPM_ZERO_HI PPM_1500_US + PPM_DEADBAND
#define PPM_STOP PPM_1000_US + PPM_DEADBAND + PPM_DEADBAND

#define STARTUP_PPM_FRAMES 50

#define PWM_FORWARD 0
#define PWM_REVERSE 1
#define PWM_IDLE 2
#define PWM_MAX 20

                 //00nN00pP
#define GPIO_FWD 0b00100001
#define GPIO_REV 0b00010010
#define GPIO_OFF 0b00000000
#define GPIO_BRK 0b00110000

/*  MAPPA PPM-PWM

    Il range di lettura del segnale PPM è di 31 step per direzione (31+31)
    La risoluzione del PWM è di 20 step (0...20)
*/
const unsigned PPM_map[] = {0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 20, 20, 20, 20, 20, 20};