main          
              MOV     R0,#3
              BL      factorial
              MOVVS   R2, #0
              MOVVC   R2,R1
              B       pgm_end

factorial     
              STMFD   SP!, {R0, LR}
              CMP     R0, #1
              BLE     less_than_two

              SUB     R0, R0, #1
              BL      factorial

              B       done

less_than_two 
              MOV     R1, #1
done          
              LDMFD   SP!, {R0, LR}
              ADDS    R1, R1, R0
              MOV     PC, LR

pgm_end       