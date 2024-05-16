.thumb
.thumb_func
.global main

.equ LED1_MASK, 0x02000
.equ LED2_MASK, 0x04000
.equ LED_ALL_MASK, (LED1_MASK+LED2_MASK)

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
  BL SET_OUT_PIN
  BL LED_OFF
loop:
  LDR R1, =LED1_MASK
  BL LED_ON
  LDR R1, =LED2_MASK
  BL LED_OFF
  BL DELAY

  LDR R1, =LED1_MASK
  BL LED_OFF
  LDR R1, =LED2_MASK
  BL LED_ON
  BL DELAY

  B loop

SET_OUT_PIN:
  STR R1, [R0, #GPIO_DIRSET_OFFSET] // set as output
  MOV PC, LR

LED_OFF:
  STR R1, [R0, #GPIO_OUTSET_OFFSET]
  MOV PC, LR

LED_ON:
  STR R1, [R0, #GPIO_OUTCLR_OFFSET]
  MOV PC, LR
  
DELAY:
  LDR R2, =16000000 // 1000ms = 1s
COUNT_DOWN:
  CMP R2, #0
  ITT NE
  SUBNE R2, R2, #1
  BNE COUNT_DOWN
  MOV PC, LR