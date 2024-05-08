.thumb
.thumb_func
.global main

.equ BTN1_MASK, 0x00800
.equ LED1_MASK, 0x02000

.equ GPIO_P0_BASE, 0x50000000
.equ GPIO_OUT_OFFSET, 0x504
.equ GPIO_IN_OFFSET, 0x510
.equ GPIO_OUTSET_OFFSET, 0x508
.equ GPIO_OUTCLR_OFFSET, 0x50C
.equ GPIO_DIR_OFFSET, 0x514
.equ GPIO_DIRSET_OFFSET, 0x518

.equ GPIO_PIN_CNF_11_OFFSET, 0x72C // 0x700 + (11 * 0x4)

main:
  LDR R0, =GPIO_P0_BASE // const vars stated in main
  BL SET_OUT_PIN
  BL CONF_BTN_PIN // PIN_CNF[11] for BTN1
loop:
  BL LED1_OFF
  BL DELAY // prevent chattering problem
  BL BTN1_WAIT

  BL LED1_ON
  BL DELAY
  BL BTN1_WAIT

  B loop

SET_OUT_PIN:
  LDR R1, =LED1_MASK
  STR R1, [R0, #GPIO_DIRSET_OFFSET] // set as output
  MOV PC, LR

// PIN_CNF
// A = 0(input), B = 0(connect input buffer), CC = 3(pull up), DDD = 0(standard 0 and 1), EE = 3(SENS for LOW)
// configs BTN as input, pulls up (active-low, high has undetermined value), reading value is either 0 or 1, not used
// 0000 0000 0000 0011 0000 0000 0000 0000 1100 = 0x0003000C
CONF_BTN_PIN:
  LDR R1, =0x0003000C
  STR R1, [R0, #GPIO_PIN_CNF_11_OFFSET]
  MOV PC, LR

DELAY:
  LDR R2, =1600000 // 100ms
COUNT_DOWN:
  CMP R2, #0
  ITT NE
  SUBNE R2, R2, #1
  BNE COUNT_DOWN
  MOV PC, LR

LED1_OFF:
  LDR R1, =LED1_MASK
  STR R1, [R0, #GPIO_OUTSET_OFFSET]
  MOV PC, LR

LED1_ON:
  LDR R1, =LED1_MASK
  STR R1, [R0, #GPIO_OUTCLR_OFFSET]
  MOV PC, LR

BTN1_WAIT:
  LDR R1, [R0, #GPIO_IN_OFFSET] // 1 if BTN off
  MVN R1, R1 // negate BTN Pin input
  TST R1, #BTN1_MASK // AND, Z flag
  IT EQ // if Z set, BTN off
  BEQ BTN1_WAIT // BTN not pressed
  MOV PC, LR
