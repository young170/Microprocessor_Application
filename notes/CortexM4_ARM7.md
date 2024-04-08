## Exception control
* privileged modes
* control register
  * APSR, IPSR, EPSR
* exception priorities
  * vector table
    * 0 - reset (reset is an exception)
    * where the PC is first pointing to
    * LR is initialized to 0xF...
    * as experienced in executing faulty code, this initialization invalidates buggy use of LR

APSR
* ARMv7-M Ref Man - p48

EPSR
* ITSTATE
  * p210
* base cond is given 3 bits and ITSTATE is given 5 bits. Base cond is distinguished using 4 bits with the lsb being either 1 or 0 depending on the cond. The msb of ITSTATE is not used unless no-cond (00000) so the first bit can be used by the base cond (reserved).

xPSR
* p624

PRIMASK, FAULTMASK, BASEPRI
* Execution priority and priority boosting - p637

CONTROL register
* p628

Memory map
* Def guide to Cor3 and Cor4 - p194
