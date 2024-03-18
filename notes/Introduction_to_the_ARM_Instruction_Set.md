
## Load-Store Instructions

use {S} to update nczv flags.
* flags are not cleared after the instruction
  * to preserve the use of the flags
    * e.g. SUB R1, #0x3 -> check `Z` flag

also, carry from `ADD` is stored in a single bit. why? 32 + 32 is max 33
an application of this is `ADDS` -> `ADC`

* mutex on pre-ARMv6 using `SWP`: [Linus Torvalds](https://lore.kernel.org/all/Pine.LNX.4.64.0512172150260.26663@localhost.localdomain/)




long pipeline (e.g. ARMv10) has another step before execution so `pc` is +8 of the current instruction (next next instruction).
