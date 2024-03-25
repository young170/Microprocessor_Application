## Branch Instructions
### `BX` vs `BLX`
Using `BX`, normal ARM2Thumb transition would be the following:
```
 MOV lr, pc
 BX foo

foo
 ...
 BX lr
```
However, using `BLX`:
```
 BLX foo

foo
 ...
 BX lr
```
The process of loading `lr` is skipped. Combined as one instruction of `BLX`.

## Load-Store Instructions
use {S} to update nczv flags.
* flags are not cleared after the instruction
  * to preserve the use of the flags
    * e.g. SUB R1, #0x3 -> check `Z` flag

also, carry from `ADD` is stored in a single bit. why? 32 + 32 is max 33
an application of this is `ADDS` -> `ADC`

### Load/Store Multiple Registers
The ARM architecture supports load/store of multiple registers using a single instruction. To support this a different instruction format is used.<br>
![load-store-multiple-registers-instruction-format](https://github.com/young170/2024-1-MA/blob/main/assets/images/load-store-multiple-registers-instruction-format.png)
The *block data transfer* instruction format provides 16-bits for registers. This allows a maximum of 4 registers to be used in each multi-register load/store because each register is addressed using 4-bits.<br>
However, after trying out the instruction by coding, found out that it supports more than 4 registers. By Googling + GPTing, found out: the ARM architecture can access the registers using offsets from the starting register.<br>
Also, learned about *register spilling*. This is when a desired register is already in use and the processor "spills" the value into memory to restore the value later.<br>

#### Why offsets?
Using offsets utilize the register ordering (done by the processor) better, and can handle discontinuous registers.<br>
First, because the registers are saved in order (R1 -> R15) the offset grows at a constant direction. This heavily simplifies the complexity of using offsets to address.<br>
Second, one can imagine there could be cases where the registers are listed in a discontinuous fashion (e.g. {R1, R3, R4, R6}). This amplifies the usage of offsets.<br>

### Loading Constants
The ARM instruction architecture doesn't support constants of 32 bits because the instruction format itself is 32 bits long.<br>
Uses a total 3 methods:
1. Use the barrel shifter to create the desired 32 bit constant (requires the least amount of cycles)
2. Use `MOV` or `MVN` to store constants in memory. Then use the registers with the constant values
3. Use PC-relative addressing to use constants

## Semaphore
* mutex on pre-ARMv6 using `SWP`: [Linus Torvalds](https://lore.kernel.org/all/Pine.LNX.4.64.0512172150260.26663@localhost.localdomain/)

Big picture:
* read lock value
* load current lock value, and store `#1` to lock **atomically**
  * `SWP` supports this
* if lock value is `#1`, then spin
* else, hold lock and access critical section

To implement the mutex in a more semaphore-like way:<br>
Create an array of semaphores and when using the `SWP` operation:
```
MOV R0, #0x0
...acquire()...
SWP ... [semaphores, R0, LSL #2]

or

MOV R0, #0x1
...acquire()...
SWP ... [semaphores, R0, LSL #2]
```
This effectively gives the index for the desired semaphore.

## Software Interrupt (SWI) Instruction
Basic flow:<br>
Save registers to stack $\rightarrow$ `BIC` `0xff000000` $\rightarrow$ `BL` (updates `lr`) to SWI handler $\rightarrow$ load registers from stack<br>
When an interrupt occurs, the mode is switched to the interrupt handling mode, but some of the low-registers are kept the same. This is because the registers (especially, R0) is used as arguments/return values.<br>

## Miscellaneous
### PC-relative addressing
When `PC` + 8 is the next instruction how is the actual next instruction (PC + 4) stored?
![mips_pipeline](https://github.com/young170/2024-1-MA/blob/main/assets/images/mips_pipeline.png)

Using an example from MIPS: when the current code is executed in the `EX` stage, the PC in the `IF` stage is **relatively** + 8.<br>
Also, one can see there already is an instruction in the `ID` stage which is the actual next instruction, PC + 4.<br>
In conclusion, PC + 8 is just the POV from the EX stage.
