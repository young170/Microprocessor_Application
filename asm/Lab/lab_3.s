.thumb
.thumb_func
.global main

.equ LED3_MASK, 0x08000

.equ GPIO_P0_BASE, 0x50000000
.equ GPIO_OUT_OFFSET, 0x504
.equ GPIO_OUTSET_OFFSET, 0x508
.equ GPIO_OUTCLR_OFFSET, 0x50C
.equ GPIO_DIR_OFFSET, 0x514
.equ GPIO_DIRSET_OFFSET, 0x518

main:
  BL SET_OUT_PIN
loop:
  BL LED_OFF
  BL DELAY_ONE_SEC

  BL LED_ON
  BL DELAY_ONE_SEC

  B loop

SET_OUT_PIN:
  LDR R0, =GPIO_P0_BASE+GPIO_DIRSET_OFFSET
  LDR R1, =LED3_MASK
  STR R1, [R0]
  MOV PC, LR

LED_ON:
  LDR R0, =GPIO_P0_BASE+GPIO_OUTCLR_OFFSET
  STR R1, [R0]
  MOV PC, LR

LED_OFF:
  LDR R0, =GPIO_P0_BASE+GPIO_OUTSET_OFFSET
  STR R1, [R0]
  MOV PC, LR

DELAY_ONE_SEC:
  LDR R2, =16000000
DELAY_LOOP:
  CMP R2, #0
  ITT NE
  SUBNE R2, R2, #1
  BNE DELAY_LOOP
  MOV PC, LR