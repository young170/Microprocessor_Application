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
