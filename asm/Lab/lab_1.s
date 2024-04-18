.thumb
.thumb_func
.global main

main:
//DIRSET register
LDR R0, =0x50000000
LDR R1, =0x02000
STR R1, [R0, #0x514]

// OUTCLR register
LDR R0, =0x50000000
LDR R1, =0x02000
STR R1, [R0, #0x50C]

loop: b loop