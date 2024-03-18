## ARM Processor
The fundamentals of an ARM processor.<br>
Contents (*, skipped):
```
Registers
Current Program Status Register
* Pipeline
Exceptions, Interrupts, and the Vector Table
Core Extensions
* Architecture Revisions + ARM Processor Families
```

### RISC
RISC stands for: Reduced Instruction Set Computer
Supports:
* Load-store architecture
  * !DMA (Direct Memory Access)
* Utilizes registers for arithmetic & memory operations

### ARM Core Dataflow
![ARM core dataflow model](https://github.com/young170/2024-1-MA/blob/main/assets/images/ARM_core_dataflow_model.png)
Interesting points:
* Von Neumann architecture
  * Data items and instructions share the same bus
* Barrel shifter
  * Can preprocess the $R_m$ register for a wider range of expressions & addresses

## Registers
Two kinds of registers:
* $r_0-r_{15}$, 16 data registers
* $cpsr, spsr$, 2 **program status registers**
  * current & saved

## Current Program Status Register
![A generic program status register](https://github.com/young170/2024-1-MA/blob/main/assets/images/program_status_register.png)
First, considering the *Control* field, the first four bits (starting form the LSb) represent the *Processor mode*<br>
* privileged
  * abort
  * fast **interrupt** request
  * **interrupt** request
  * supervisor
  * system
  * undefined
* nonprivileged
  * user
Each processor mode holds different sets of registers for their use<br>
There are two separate modes that deal with interrupts. This is because ARM supports multiple levels (priorities) of interrupts<br>

### Banked Registers
There are acually a total of 37 registers in the register file. Among the registers, 20 of them are hidden at different times<br>
The registers are swapped when an **interrupt** forces a mode change. The previously used registers are *banked* and replaced by the mode's registers<br>

### State and Instruction Sets
* ARM
* Thumb
  * 16-bit instruction version of ARM
* Jazelle
  * Provides execution of Java bytecodes
 
### Interrupt Masks
Used to stop specific interrupt requests from interrupting the processor
* Mask either IRQ (interrupt request) or FIQ (fast interrupt request)

### Condition Flags
Helps boost optimization by updating condition flags based on the result of ALU operations that specify the `S` instruction suffix<br>
The flags: NZCV, are useful when doing binary arithmetic<br>
A result is confirmed negative when `Nv` or `nV`<br>
The `Z` flag is very useful for distinguishing similar operations.<br>
For example, there exists LT and GE. To implement a GT, a `z` flag is added into the condition flags to remove the equal condition.

Flags are updated during *Data Processing Instructions* such as, `MOV` or `ADD`.<br>
However, the `{S}` optional syntax needs to be specified. For conditional instructions (e.g. `AND`, `ORR`) this is not needed.
```
Syntax: <instruction>{cond}{S} Rd, Rn, Rm
```

There are 15 conditional flag combinations, but 4-bits are used. The last combination of `1111` means "always execute" disregarding conditions.<br>

## Exceptions, Interrupts, and the Vector Table

### Nested Vectored Interrupt Controller
**Nested**: there are multiple levels of priorites of interrupts<br>
**Vectored**: using a **Vector Table**, the branch of ISR (Interrupt Service Routine) is determined
* each entry consists of an *interrupt vector* pair: interrupt request - interrupt handler
  * the <interrupt handler> entry is actually in a form of a branch instruction
  * the branch instruction points to the start of the specific interrupt's handler
* address either starts at `0x00000000` or `0xffff0000`

## Core Extensions
Standard components placed next to the ARM core.

### Cache and Tightly Coupled Memory
There are two versions of architectures: Von Neumann-style and Harvard-style<br>
First, Von Neumann-style:<br>
Using the AMBA (Advanced Microcontroller Bus Architecture) bus protocol, the *unified cache* works together with the ARM core<br>
Compared to, Harvard-style:<br>
Uses **tightly coupled memory** (TCM): **guarantees** the clock cycles required to fetch instructions or data
* Why is this important?
  * For real-time algorithms, a deterministic behavior is critical
 
### Memory Management
**MMU** vs **MPU**
* Memory management unit: provides **translation** from virtual-to-physical addresses.
  * Can load more complex OS such as Linux.
* Memory protection unit: each region is defined with specific access permissions.
Difference is how memory is mapped.

## Miscellaneous
* big.LITTLE
