/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

#include <stdint.h>

#define LED1_MASK 0x00002000
#define LED2_MASK 0x00004000
#define LED3_MASK 0x00008000
#define LED4_MASK 0x00010000
#define LED_ALL_MASK (LED1_MASK+LED2_MASK+LED3_MASK+LED4_MASK)
#define GPIO_P0_BASE 0x50000000
#define GPIO_OUT_REG_OFFSET 0x0504
#define GPIO_OUTSET_REG_OFFSET 0x0508
#define GPIO_OUTCLR_REG_OFFSET 0x050C
#define GPIO_DIR_REG_OFFSET 0x0514
#define GPIO_DIRSET_REG_OFFSET 0x0518

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
int
main(void) {
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
  volatile uint32_t *dir_reg = (uint32_t *)(GPIO_P0_BASE + GPIO_DIRSET_REG_OFFSET);
  *dir_reg = LED1_MASK;
}

volatile void
DELAY() {
  __asm volatile (
      "LDR R2, =16000000\n"
    "DELAY_LOOP:\n\t"
      "CMP R2, #0\n\t"
      "ITT NE\n\t"
      "SUBNE R2, R2, #1\n\t"
      "BNE DELAY_LOOP\n\t"
  );
}

volatile void
LED_OFF() {
  volatile uint32_t *outset_reg = (uint32_t *)(GPIO_P0_BASE + GPIO_OUTSET_REG_OFFSET);
  *outset_reg = LED1_MASK;
}

volatile void
LED_ON() {
  volatile uint32_t *outset_reg = (uint32_t *)(GPIO_P0_BASE + GPIO_OUTCLR_REG_OFFSET);
  *outset_reg = LED1_MASK;
}

/*************************** End of file ****************************/
