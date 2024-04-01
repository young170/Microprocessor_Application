start         
              MOV     R0, #6
              BL      fibo
              B       end_pgm

fibo          
              STMFD   SP!, {R0-R2, LR}
              CMP     R0, #1
              MOVEQ   R3, #1
              MOVLT   R3, #0
              BLE     done

              SUB     R0, R0, #1
              BL      fibo
              MOV     R2, R3

              SUB     R0, R0, #1
              BL      fibo

              ADD     R3, R2, R3

less_than_two 


done          
              LDMFD   SP!, {R0-R2, LR}
              MOV     PC, LR

end_pgm       ;       end of program

