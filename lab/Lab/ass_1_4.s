.thumb
.thumb_func
.global main

.equ BTN1_MASK, 0x0000800
.equ BTN2_MASK, 0x0001000
.equ BTN3_MASK, 0x1000000
.equ BTN4_MASK, 0x2000000
.equ LED1_MASK, 0x0002000
.equ LED2_MASK, 0x0004000
.equ LED3_MASK, 0x0008000
.equ LED4_MASK, 0x0010000
.equ LED_ALL_MASK, (LED1_MASK+LED2_MASK+LED3_MASK+LED4_MASK)
.equ BTN_ALL_MASK, (BTN1_MASK+BTN2_MASK+BTN3_MASK+BTN4_MASK)

.equ GPIO_P0_BASE, 0x50000000
.equ GPIO_OUT_OFFSET, 0x504
.equ GPIO_IN_OFFSET, 0x510
.equ GPIO_OUTSET_OFFSET, 0x508
.equ GPIO_OUTCLR_OFFSET, 0x50C
.equ GPIO_DIR_OFFSET, 0x514
.equ GPIO_DIRSET_OFFSET, 0x518

.equ GPIO_PIN_CNF_11_OFFSET, 0x72C
.equ GPIO_PIN_CNF_12_OFFSET, 0x730
.equ GPIO_PIN_CNF_24_OFFSET, 0x760
.equ GPIO_PIN_CNF_25_OFFSET, 0x764

main:
  LDR R0, =GPIO_P0_BASE
  LDR R1, =LED_ALL_MASK
  BL SET_OUT_PIN
  BL LED_OFF
  BL CONF_BTN_PIN
loop:
  BL DELAY // prevent chattering problem
  BL BTN_WAIT
  BL LED_TOGGLE

  B loop

SET_OUT_PIN:
  STR R1, [R0, #GPIO_DIRSET_OFFSET]
  MOV PC, LR

// PIN_CNF
// A = 0(input), B = 0(connect input buffer), CC = 3(pull up), DDD = 0(standard 0 and 1), EE = 3(SENS for LOW)
// 0000 0000 0000 0011 0000 0000 0000 0000 0011 = 0x0003000C
CONF_BTN_PIN:
  LDR R1, =0x0003000C
  STR R1, [R0, #GPIO_PIN_CNF_11_OFFSET] // configure BTN1
  STR R1, [R0, #GPIO_PIN_CNF_12_OFFSET] // configure BTN2
  STR R1, [R0, #GPIO_PIN_CNF_24_OFFSET] // configure BTN3
  STR R1, [R0, #GPIO_PIN_CNF_25_OFFSET] // configure BTN4
  MOV PC, LR

DELAY:
  LDR R2, =16000000 // 1000ms = 1s
COUNT_DOWN:
  CMP R2, #0
  ITT NE
  SUBNE R2, R2, #1
  BNE COUNT_DOWN
  MOV PC, LR

LED_OFF:
  STR R1, [R0, #GPIO_OUTSET_OFFSET]  
  MOV PC, LR

LED_TOGGLE:
  LDR R1, [R0, #GPIO_OUT_OFFSET]

  EOR R2, R1, R3 // EOR OUT : LED_MASK

  STR R2, [R0, #GPIO_OUT_OFFSET]
  MOV PC, LR

BTN_WAIT:
  LDR R1, [R0, #GPIO_IN_OFFSET]
  MVN R1, R1

  TST R1, #BTN1_MASK // is BTN1 pressed?
  ITT NE
  LDRNE R3, =LED1_MASK
  MOVNE PC, LR

  TST R1, #BTN2_MASK // is BTN2 pressed?
  ITT NE
  LDRNE R3, =LED2_MASK
  MOVNE PC, LR

  TST R1, #BTN3_MASK // is BTN3 pressed?
  ITT NE
  LDRNE R3, =LED3_MASK
  MOVNE PC, LR

  TST R1, #BTN4_MASK // is BTN4 pressed?
  ITT NE
  LDRNE R3, =LED4_MASK
  MOVNE PC, LR

  BEQ BTN_WAIT // either BTN not pressed
