       mov     r5, #0x00000002
       mov     r4, #0x00000003
       ldr     sp, =data
       stmdb   sp!, {r4, r5} ; the order the registers are stored is very interesting

data   DCD     0x44444444