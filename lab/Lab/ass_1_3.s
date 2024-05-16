.thumb
.thumb_func
.global main

.equ BTN1_MASK, 0x00800
.equ BTN2_MASK, 0x01000
.equ LED1_MASK, 0x02000
.equ LED2_MASK, 0x04000
.equ LED_ALL_MASK, (LED1_MASK+LED2_MASK)
.equ BTN_ALL_MASK, (BTN1_MASK+BTN2_MASK)

.equ GPIO_P0_BASE, 0x50000000
.equ GPIO_OUT_OFFSET, 0x504
.equ GPIO_IN_OFFSET, 0x510
.equ GPIO_OUTSET_OFFSET, 0x508
.equ GPIO_OUTCLR_OFFSET, 0x50C
.equ GPIO_DIR_OFFSET, 0x514
.equ GPIO_DIRSET_OFFSET, 0x518

.equ GPIO_PIN_CNF_11_OFFSET, 0x72C
.equ GPIO_PIN_CNF_12_OFFSET, 0x730

main:
  LDR R0, =GPIO_P0_BASE
  LDR R1, =LED_ALL_MASK
  BL SET_OUT_PIN
  BL LED_OFF
  BL CONF_BTN_PIN
loop:
  BL DELAY // prevent chattering problem
  BL BTN_WAIT

  LDR R3, =LED1_MASK
  LDR R4, =LED2_MASK
  ORR R3, R3, R4
  BL LED_TOGGLE

  B loop

SET_OUT_PIN:
  STR R1, [R0, #GPIO_DIRSET_OFFSET]
  MOV PC, LR

// PIN_CNF
// A = 0(input), B = 0(connect input buffer), CC = 3(pull up), DDD = 0(standard 0 and 1), EE = 3(SENS for LOW)
// 0000 0000 0000 0011 0000 0000 0000 0000 1100 = 0x0003000C
CONF_BTN_PIN:
  LDR R1, =0x0003000C
  STR R1, [R0, #GPIO_PIN_CNF_11_OFFSET] // configure BTN1
  STR R1, [R0, #GPIO_PIN_CNF_12_OFFSET] // configure BTN2
  MOV PC, LR

DELAY:
  LDR R2, =1600000 // 100ms
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

  AND R2, R1, R3 // mask other bits as 0
  EOR R2, R2, R3 // negate curr value

  STR R2, [R0, #GPIO_OUT_OFFSET]
  MOV PC, LR

BTN_WAIT:
  LDR R1, [R0, #GPIO_IN_OFFSET]
  MVN R1, R1

  TST R1, #BTN1_MASK // is BTN1 pressed?
  IT NE
  MOVNE PC, LR

  TST R1, #BTN2_MASK // is BTN2 pressed?
  IT NE
  MOVNE PC, LR

  BEQ BTN_WAIT // either BTN not pressed