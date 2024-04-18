```
main:
  LDR R0, =GPIO_P0_BASE
  BL SET_OUT_PIN
  LDR R1, =LED_ALL_MASK
  BL LED_OFF
loop:
  LDR R1, =LED1_MASK
  BL LED_ON
  LDR R1, =LED2_MASK
  BL LED_OFF
  BL DELAY

  LDR R1, =LED1_MASK
  BL LED_OFF
  LDR R1, =LED2_MASK
  BL LED_ON
  BL DELAY

  B loop
```

vs

```
main:
  LDR R0, =GPIO_P0_BASE
  BL SET_OUT_PIN
  BL LED_ALL_OFF
loop:
  BL LED1_ON
  BL LED2_OFF
  BL DELAY

  BL LED1_OFF
  BL LED2_ON
  BL DELAY

  B loop
```

Trade-off between memory compactness of code vs slight-readability.

Considering the target of ASM code, maybe the first one is more suitable.
