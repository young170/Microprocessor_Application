start   
        MOV     R0, #5
        BL      fibo
        B       end_pgm

fibo    
        STMFD   SP!, {R0-R1, LR}
        CMP     R0, #1
        MOVEQ   R3, #1
        MOVLT   R3, #0
        BLE     done

        SUB     R0, R0, #1
        BL      fibo
        MOV     R1, R3 ; return value to R1

        SUB     R0, R0, #1
        BL      fibo

        ADD     R3, R1, R3 ; fibo(n - 1) + fibo(n - 2)

done    
        LDMFD   SP!, {R0-R1, LR}
        MOV     PC, LR

end_pgm ;       end of program

