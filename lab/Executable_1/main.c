#include <stdint.h>

#include <stdint.h>
#define LED1_MASK 0x00002000
#define LED2_MASK 0x00004000
#define LED_ALL_MASK (LED1_MASK+LED2_MASK)
#define BTN1_MASK 0x00800
#define BTN2_MASK 0x01000
#define GPIO_P0_BASE 0x50000000
#define GPIO_OUT_REG_OFFSET 0x0504
#define GPIO_IN_REG_OFFSET 0x510
#define GPIO_OUTSET_REG_OFFSET 0x0508
#define GPIO_DIR_REG_OFFSET 0x0514
#define GPIO_DIRSET_REG_OFFSET 0x0518
#define BTN_PIN_CNF 0x0003000c
#define GPIO_PIN_CNF_11_OFFSET 0x72C
#define GPIO_PIN_CNF_12_OFFSET 0x730

void volatile gpio_setting() 
{
  volatile uint32_t *dirset_reg = 
    (uint32_t*)(GPIO_P0_BASE+GPIO_DIRSET_REG_OFFSET);
  *dirset_reg = LED1_MASK + LED2_MASK;

  volatile uint32_t *outset_reg = 
    (uint32_t*)(GPIO_P0_BASE+GPIO_OUTSET_REG_OFFSET);
  *outset_reg = LED1_MASK + LED2_MASK;

  volatile uint32_t *pincnf_11_reg = 
    (uint32_t*)(GPIO_P0_BASE+GPIO_PIN_CNF_11_OFFSET);
  *pincnf_11_reg = BTN_PIN_CNF;

  volatile uint32_t *pincnf_12_reg = 
    (uint32_t*)(GPIO_P0_BASE+GPIO_PIN_CNF_12_OFFSET);
  *pincnf_12_reg = BTN_PIN_CNF;
}

void volatile delay_loop() {
  __asm(
      "LDR R2, =1600000\n\t"
      "CNT_LOOP: CMP R2, #0\n\t"
      "ITT NE\n\t"
      "SUBNE R2, R2, #1\n\t"
      "BNE CNT_LOOP\n\t"
      "MOV PC, LR\n\t"
    );
}

void volatile led_toggle() {
  volatile uint32_t *out_reg = 
    (uint32_t*)(GPIO_P0_BASE+GPIO_OUT_REG_OFFSET);
  volatile uint32_t gpio_out_val = *out_reg;

  if (((gpio_out_val & LED1_MASK) == 0) || ((gpio_out_val & LED2_MASK) == 0)) {
    *out_reg = gpio_out_val | (LED1_MASK | LED2_MASK);
  } else {
    *out_reg = gpio_out_val & (!(LED1_MASK) || !(LED2_MASK));

  }
}

void volatile btn_toggle() {
  volatile uint32_t *in_reg = 
    (uint32_t*)(GPIO_P0_BASE+GPIO_IN_REG_OFFSET);
  volatile uint32_t gpio_in_val = *in_reg;
  
  if ((gpio_in_val & BTN1_MASK) == 0) {
    led_toggle();
  } else if ((gpio_in_val & BTN2_MASK) == 0) {
    led_toggle();
  }

}

int main()
{
  gpio_setting();

   while(1) 
   {
     delay_loop();
     btn_toggle();
   }
   return 0;
}
