//.syntax unified                     
.thumb
.thumb_func

.equ BTN1_MASK, 0x00800
.equ BTN2_MASK, 0x01000
.equ LED1_MASK, 0x02000
.equ LED2_MASK, 0x04000
.equ LED3_MASK, 0x08000
.equ LED4_MASK, 0x10000

.equ GPIO_P0_BASE, 0x50000000
.equ GPIO_DIRSET_REG_OFFSET, 0x518
.equ GPIO_OUT_REG_OFFSET, 0x504
.equ GPIO_PIN_CNF_11_OFFSET,    0x72C  // P0.11 pin configuration address offset (BTN1)

.equ GPIOTE_BASE, 0x40006000
.equ GPIOTE_INTENSET_OFFSET, 0x304
.equ GPIOTE_CONFIG0_OFFSET, 0x510 // GPIOTE channel 0
.equ GPIOTE_EVENT_IN0, 0x40006100

.section .text                      
.global main

main:
  BL GPIO_SETUP
  BL GPIOTE_SETUP
  BL NVIC_SETUP
  WFI
  B .
//myLoop: B myLoop

 
GPIO_SETUP:
  // LED1 setting
  LDR R0, =GPIO_P0_BASE
  LDR R1, =LED1_MASK
  STR R1, [R0, #GPIO_DIRSET_REG_OFFSET]

  // Button1 setting
  LDR R1, =0x0003000c
  //LDR R1, =0x0000000c
  STR R1, [R0, #GPIO_PIN_CNF_11_OFFSET]
  
  MOV PC,LR

GPIOTE_SETUP:
  // GPIOTE setting
  LDR R0, =GPIOTE_BASE

  // Channel 0 interrupt setting 
  MOV R1, #0x01 // channel = 0
  STR R1, [R0, #GPIOTE_INTENSET_OFFSET]

  // PIN_CNF[11] configurations
  // for mode setting and pin number setting
  MOV R1, (    ) // mode = event
  MOV R2, (    )   // pin number = 11
  LSL R2, R2, #8 // shift bits to PSEL place (BBBBB)
  ORR R1, R1, R2

  // for port number setting
  MOV R2, (    ) // port number = 0
  LSL R2, R2, #13 // shift bits to PORT place (C)
  ORR R1, R1, R2
  
  // for Polarity setting
  MOV R2,(    )  // polarity = HiToLo (2)
  LSL R2, R2, #16 // shift bits to PORT place (DD)
  ORR R1, R1, R2
  
  // setting GPIOTE_PIN_CONFIG[11]
  STR R1, [               ]
  
  BX LR //MOV PC, LR

NVIC_SETUP:
  // NVIC setting

  // set R0 as base address of NVIC
   LDR R0, =0xE000E100 // interrupt set-enable register

  // set interrupt Enable for interrupt from GPIOTE (interrupt number 6) 



  // set interrupt priority for GPIOTE interrupt
  // set R0 as base address for interrupt priority register 
  LDR R0, =0xE000E400 // interrupt priority register
  
 // set GPIOTE interrupt priority as 2 for interrupt from GPIOTE (interrupt number 6)


  BX LR  // return

led1Toggle:
  LDR R0, =GPIO_P0_BASE
  LDR R1, [R0, #GPIO_OUT_REG_OFFSET]
  EORS R1, R1, #LED1_MASK
  STR R1, [R0, #GPIO_OUT_REG_OFFSET]
  BX LR   // return

.global GPIOTE_Handler
GPIOTE_Handler:
  // PUSH : save the LR value to stack 
  
  // Check if interrupt source is Button1 (GPIOTE channel 0)
  // By looking at the bit 0 of EVENT_IN0 (channel 0) register of GPIOTE
   

  BEQ EXIT_GPIOTE_Handler  // If No Button1 Event, Skip the Handler

  BL led1Toggle

  // Prepare Exiting the interrupt handler by
  // Clearing the bit 0 of EVENT_IN0 (channel 0) register of GPIOTE

  
EXIT_GPIOTE_Handler:
  // POP: retrievd the saved LR value from the stack 
  
  
  // return from ISR

