       LDR     r0, =data

loop   
       LDRB    r1, [r0], #1
       SUB     r3, r1, #0x01
       CMP     r1, #0
       BNE     loop
       MOV     r2, #1

data   DCB     0x01, 0x02, 0x03, 0x04