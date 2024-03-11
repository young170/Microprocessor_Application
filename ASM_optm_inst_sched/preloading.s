       LDR     r0, =data
       LDRB    r1, [r0], #1
loop   
       SUB     r3, r1, #0x01
       CMP     r1, #0
       BEQ     stop
       LDRB    r1, [r0], #1

stop   

data   DCB     0x01, 0x02, 0x03, 0x04