.thumb
.thumb_func
.global main

.equ LED1_MASK, 0x02000
.equ LED2_MASK, 0x04000
.equ LED3_MASK, 0x08000
.equ LED4_MASK, 0x10000
.equ LED_ALL_MASK, (LED1_MASK+LED2_MASK+LED3_MASK+LED4_MASK)

.equ GPIO_P0_BASE, 0x50000000
.equ GPIO_OUT_OFFSET, 0x504
.equ GPIO_IN_OFFSET, 0x510
.equ GPIO_OUTSET_OFFSET, 0x508
.equ GPIO_OUTCLR_OFFSET, 0x50C
.equ GPIO_DIR_OFFSET, 0x514
.equ GPIO_DIRSET_OFFSET, 0x518

main:
  LDR R0, =GPIO_P0_BASE 
  LDR R1, =LED_ALL_MASK
  STR R1, [R0, #GPIO_DIRSET_OFFSET] // set all LED_MASKs as output

  LDR R1, =LED_ALL_MASK
  BL LED_OFF // initially turn off all LED

  LDR R1, =LED1_MASK // start as LED1

loop:
  BL LED_ON
  BL DELAY
  BL LED_OFF
  
  LSL R1, R1, #1 // shift LED_MASK
  CMP R1, #LED4_MASK // if shifted from LED4_MASK
  IT GT
  LDRGT R1, =LED1_MASK // reset mask to LED1_MASK

  B loop

DELAY:
  LDR R2, =16000000 // 1000ms
COUNT_DOWN:
  CMP R2, #0
  ITT NE
  SUBNE R2, R2, #1
  BNE COUNT_DOWN
  MOV PC, LR

LED_OFF:
  STR R1, [R0, #GPIO_OUTSET_OFFSET]
  MOV PC, LR

LED_ON:
  STR R1, [R0, #GPIO_OUTCLR_OFFSET]
  MOV PC, LR