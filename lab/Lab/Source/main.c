/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

#include <stdint.h>

void volatile SET_DIR_PIN(void);
void volatile DELAY(void);
void volatile LED_OFF(void);
void volatile LED_ON(void);

/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/
int main(void) {
  SET_DIR_PIN();

  while (1) {
    LED_OFF();
    DELAY();
    LED_ON();
    DELAY();
  }
}

volatile void
SET_DIR_PIN() {
  __asm volatile (
    "LDR R0, =0x50000000\n\t"
    "LDR R1, =0x02000\n\t"
    "STR R1, [R0, #0x514]\n\t"
  );
}

void volatile DELAY() {
  __asm volatile (
      "LDR R2, =16000000\n"
    "DELAY_LOOP:\n\t"
      "CMP R2, #0\n\t"
      "ITT NE\n\t"
      "SUBNE R2, R2, #1\n\t"
      "BNE DELAY_LOOP\n\t"
      //"MOV PC, LR\n\t"
  );
}

void volatile LED_OFF() {
  __asm volatile (
    "LDR R0, =0x50000000\n\t"
    "LDR R1, =0x02000\n\t"
    "STR R1, [R0, #0x508]\n\t"
    //"MOV PC, LR\n\t"
  );
}

void volatile LED_ON() {
  __asm volatile (
    "LDR R0, =0x50000000\n\t"
    "LDR R1, =0x02000\n\t"
    "STR R1, [R0, #0x50C]\n\t"
    //"MOV PC, LR\n\t"
  );
}

/*************************** End of file ****************************/
