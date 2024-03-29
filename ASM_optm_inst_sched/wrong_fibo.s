start         
              MOV     R0, #1
              BL      fibo
              B       end_pgm

fibo          
              STMFD   SP!, {R0-R2, LR}
              CMP     R0, #2
              BLE     less_than_two

              SUB     R1, R0, #1
              mov     r0, r1
              BL      fibo
              mov     r2, r0

              SUB     R1, R1, #1
              mov     r0, r1
              BL      fibo
              ADD     r0, r0, r2

              b       done

less_than_two 
              CMP     r0, #0
              moveq   r0, #0
              movne   r0, #1

done          
              LDMFD   SP!, {R0-R2, LR}
              MOV     PC, LR

end_pgm       ;       end of program
