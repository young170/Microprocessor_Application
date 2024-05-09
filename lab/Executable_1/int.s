.thumb
.thumb_func
.equ BTN1_MASK, 0x00800
.equ BTN2_MASK, 0x01000
.equ LED1_MASK, 0x02000
.equ LED2_MASK, 0x04000
.equ LED_ALL_MASK, (LED1_MASK+LED2_MASK)
.equ GPIO_P0_BASE, 0x50000000
.equ GPIO_DIRSET_REG_OFFSET, 0x518
.equ GPIO_OUT_REG_OFFSET, 0x504
.equ GPIO_OUTSET_REG_OFFSET, 0x508
.equ GPIO_PIN_CNF_11_OFFSET, 0x72C
.equ GPIO_PIN_CNF_12_OFFSET, 0x730
.equ GPIOTE_BASE, 0x40006000
.equ GPIOTE_INTENSET_OFFSET, 0x304
.equ GPIOTE_CONFIG0_OFFSET, 0x510 // GPIOTE channel 0
.equ GPIOTE_CONFIG1_OFFSET, 0x514 // GPIOTE channel 1
.equ GPIOTE_EVENT_IN0, 0x40006100
.equ GPIOTE_EVENT_IN1, 0x40006104
.section .text
.global main
main:
  BL GPIO_SETUP
  BL GPIOTE_SETUP
  BL NVIC_SETUP
  WFI
  B .

GPIO_SETUP:
  // LED1 setting
  LDR R0, =GPIO_P0_BASE
  LDR R1, =LED_ALL_MASK
  STR R1, [R0, #GPIO_DIRSET_REG_OFFSET]
  STR R1, [R0, #GPIO_OUTSET_REG_OFFSET]
  // Button1 setting
  LDR R1, =0x0003000c
  STR R1, [R0, #GPIO_PIN_CNF_11_OFFSET]
  STR R1, [R0, #GPIO_PIN_CNF_12_OFFSET]

  MOV PC,LR

GPIOTE_SETUP:
  // GPIOTE setting
  LDR R0, =GPIOTE_BASE
  MOV R1, #0x03 // channel = 0 and 1
  STR R1, [R0, #GPIOTE_INTENSET_OFFSET]

  // setup GPIOTE.CONFIG[0] for INT Channel 0
  MOV R1, #0x01 // mode = event
  MOV R2, #11 // pin number = 11
  LSL R2, R2, #8 // shift bits to PSEL place (BBBBB)
  ORR R1, R1, R2
  MOV R2, #0x00 // port number = 0
  LSL R2, R2, #13 // shift bits to PORT place (C)
  ORR R1, R1, R2
  MOV R2, #0x02 // polarity = HiToLo
  LSL R2, R2, #16 // shift bits to PORT place (DD)
  ORR R1, R1, R2
  STR R1, [R0, #GPIOTE_CONFIG0_OFFSET]

  // setup GPIOTE.CONFIG[1] for INT Channel 1
  MOV R1, #0x01 // mode = event
  MOV R2, #12 // pin number = 12
  LSL R2, R2, #8 // shift bits to PSEL place (BBBBB)
  ORR R1, R1, R2
  MOV R2, #0x00 // port number = 0
  LSL R2, R2, #13 // shift bits to PORT place (C)
  ORR R1, R1, R2
  MOV R2, #0x02 // polarity = HiToLo
  LSL R2, R2, #16 // shift bits to PORT place (DD)
  ORR R1, R1, R2
  STR R1, [R0, #GPIOTE_CONFIG1_OFFSET]

  BX LR // return

NVIC_SETUP:
  // NVIC setting
  LDR R0, =0xE000E100 // interrupt set-enable register
  MOV R1, #(1<<6) // GPIOTE interrupt number = 6
  STR R1, [R0]
  LDR R0, =0xE000E400 // interrupt priority register
  MOV R1, #2 // It doesn't have to be at the top priority
  STR R1, [R0 , #6] // GPIOTE interrupt number = 6
  BX LR // return

.global GPIOTE_Handler
// Interrupt Handler for GPIOTE Event
GPIOTE_Handler:
  PUSH {LR}

  // Check if the interrupt source is Button1 Event (GPIOTE channel 0)
  LDR R0, =GPIOTE_EVENT_IN0
  LDR R1, [R0] // Read GPIOTE Event In0
  TST R1, #1 // Check if Event In0 occurred
  // Perform LED toggle Task
  IT NE
  BLNE led1Toggle
  ITTTT NE
  // clear Event in GPIOTE Event Reg
  LDRNE R0, =GPIOTE_EVENT_IN0
  MOVNE R1, #0
  STRNE R1, [R0] // GPIOTE.EVENTS_IN[0] clear
  BNE EXIT_GPIOTE_Handler

  // Check if the interrupt source is Button1 Event (GPIOTE channel 1)
  LDR R0, =GPIOTE_EVENT_IN1
  LDR R1, [R0] // Read GPIOTE Event In1
  TST R1, #1 // Check if Event In1 occurred
  // Perform LED toggle Task
  IT NE
  BLNE led1Toggle
  ITTTT NE
  // clear Event in GPIOTE Event Reg
  LDRNE R0, =GPIOTE_EVENT_IN1
  MOVNE R1, #0
  STRNE R1, [R0] // GPIOTE.EVENTS_IN[1] clear
  BNE EXIT_GPIOTE_Handler

EXIT_GPIOTE_Handler:
  POP {LR}
  BX LR

led1Toggle:
  LDR R0, =GPIO_P0_BASE
  LDR R1, [R0, #GPIO_OUT_REG_OFFSET]
  LDR R3, =LED1_MASK
  LDR R4, =LED2_MASK
  ORR R2, R3, R4

  EOR R1, R1, R2

  STR R1, [R0, #GPIO_OUT_REG_OFFSET]

  MOV PC,LR
