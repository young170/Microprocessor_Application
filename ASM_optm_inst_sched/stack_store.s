       MOV     R0, #0x200
       MOV     R1, #0x1
       MOV     R2, #0x2
       MOV     R3, #0x3
       MOV     R4, #0x4
       MOV     R5, #0x5
       MOV     R6, #0x6
       MOV     R7, #0x7
       MOV     R8, #0x8

       ; STMIA   R0, {R1-R4}

       STR     R4, [R0], #0x4
       STR     R3, [R0], #0x4
       STR     R2, [R0], #0x4
       STR     R1, [R0], #0x4

data   
       DCD     0x00000002, 0x00000004, 0x00000006, 0x00000008, 0x0000000A, 0x0000000C