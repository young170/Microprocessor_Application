/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Generic application start

*/

#include <stdint.h>

#define LED1_MASK 0x00002000 // 0b10000000000000, 1...13(0)
#define LED2_MASK 0x00004000
#define LED3_MASK 0x00008000
#define LED4_MASK 0x00010000
#define LED_ALL_MASK (LED1_MASK+LED2_MASK+LED3_MASK+LED4_MASK)
#define LED_MASK_SHFT 13 // shift 13 bits

#define BTN1_MASK 0x0000800
#define GPIO_PIN_CNF_11_OFFSET 0x72C

#define GPIO_P0_BASE 0x50000000
#define GPIO_IN_REG_OFFSET 0x510
#define GPIO_OUT_REG_OFFSET 0x0504
#define GPIO_OUTSET_REG_OFFSET 0x0508
#define GPIO_OUTCLR_REG_OFFSET 0x050C
#define GPIO_DIR_REG_OFFSET 0x0514
#define GPIO_DIRSET_REG_OFFSET 0x0518

volatile void SETTINGS (void);
volatile void WAIT_INPUT_PUSH(void);
volatile uint32_t change_led_mask (uint32_t);
volatile void control_led_output (uint32_t);

/*********************************************************************
*
*       main()
*
*  Function description
*   Application entry point.
*/
int
main(void)
{
  SETTINGS();

  uint32_t curr_led_state = 0b00;
  uint32_t led_mask = 0;

  while (1) {
    if (curr_led_state > 0b11) {
      curr_led_state = 0b00;
    }

    // on push event
    WAIT_INPUT_PUSH();

    // choose led mask
    led_mask = change_led_mask(curr_led_state);

    // set given led using out
    control_led_output(led_mask);

    curr_led_state++;
  }

  return 0;
}

volatile void
SETTINGS ()
{
  volatile uint32_t *dir_reg = (uint32_t *)(GPIO_P0_BASE + GPIO_DIRSET_REG_OFFSET);
  *dir_reg = LED_ALL_MASK;

  volatile uint32_t *outset_reg = (uint32_t *)(GPIO_P0_BASE + GPIO_OUTSET_REG_OFFSET);
  *outset_reg = LED_ALL_MASK;

  volatile uint32_t *pin_cnf_11 = (uint32_t *)(GPIO_P0_BASE + GPIO_PIN_CNF_11_OFFSET);
  *pin_cnf_11 = 0x0003000c;
}

volatile void
WAIT_INPUT_PUSH()
{
  while(1) {
    volatile uint32_t button_state = *((uint32_t *)(GPIO_P0_BASE+GPIO_IN_REG_OFFSET));
    button_state = ~button_state;

    if(button_state & BTN1_MASK) {
      break;
    }
  }
}

volatile uint32_t
change_led_mask (uint32_t led_state)
{
  led_state = ~led_state; // active-low, OUT-0-low
  return led_state << LED_MASK_SHFT;
}

volatile void
control_led_output (uint32_t led_mask)
{
  volatile uint32_t *out_reg = (uint32_t *)(GPIO_P0_BASE + GPIO_OUT_REG_OFFSET);
  *out_reg = led_mask;
}

/*************************** End of file ****************************/
