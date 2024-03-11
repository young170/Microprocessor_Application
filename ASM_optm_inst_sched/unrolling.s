       LDR     r0, =data

loop   
       LDRB    r1, [r0], #1
       LDRB    r2, [r0], #1
       LDRB    r3, [r0], #1
       SUB     r3, r1, #0x01
       CMP     r1, #0
       BEQ     stop

stop   

data   DCB     0x01, 0x02, 0x03, 0x04

; unrolling: multiple runs of the instruction
; in this case, assumes (at most) two chars are read after the end of the string
; however, if at the end of RAM, will cause data abort.
; disadvantages: (1) slower for short strings, (2) may pointlessly process adiitional chars.