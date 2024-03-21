
## Load-Store Instructions

use {S} to update nczv flags.
* flags are not cleared after the instruction
  * to preserve the use of the flags
    * e.g. SUB R1, #0x3 -> check `Z` flag

also, carry from `ADD` is stored in a single bit. why? 32 + 32 is max 33
an application of this is `ADDS` -> `ADC`

* mutex on pre-ARMv6 using `SWP`: [Linus Torvalds](https://lore.kernel.org/all/Pine.LNX.4.64.0512172150260.26663@localhost.localdomain/)

long pipeline (e.g. ARMv10) has another step before execution so `pc` is +8 of the current instruction (next next instruction).

### Load/Store Multiple Registers
The ARM architecture supports load/store of multiple registers using a single instruction. To support this a different instruction format is used.<br>
![load-store-multiple-registers-instruction-format](https://github.com/young170/2024-1-MA/blob/main/assets/images/load-store-multiple-registers-instruction-format.png)
The *block data transfer* instruction format provides 16-bits for registers. This allows a maximum of 4 registers to be used in each multi-register load/store because each register is addressed using 4-bits.<br>
However, after trying out the instruction by coding, found out that it supports more than 4 registers. By Googling + GPTing, found out: the ARM architecture can access the registers using offsets from the starting register.<br>
Also, learned about *register spilling*. This is when a desired register is already in use and the processor "spills" the value into memory to restore the value later.<br>

#### Why offsets?
Using offsets utilize the register ordering (done by the processor) better, and can handle discontinuous registers.<br>
First, because the registers are saved in order (r1 -> r15) the offset grows at a constant direction. This heavily simplifies the complexity of using offsets to address.<br>
Second, one can imagine there could be cases where the registers are listed in a discontinuous fashion (e.g. {R1, R3, R4, R6}). This amplifies the usage of offsets.<br>

## Semaphore

## Software Interrupt (SWI) Instruction
Basic flow:<br>
Save registers to stack $\rightarrow$ `BIC` `0xff000000` $\rightarrow$ `BL` (updates `lr`) to SWI handler $\rightarrow$ load registers from stack<br>
When an interrupt occurs, the mode is switched to the interrupt handling mode, but some of the low-registers are kept the same. This is because the registers (especially, R0) is used as arguments/return values.<br>

## Miscellaneous
### PC-relative addressing
