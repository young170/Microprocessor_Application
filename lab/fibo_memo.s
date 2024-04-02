.section .data

fibo_cache:
	.word -1, -1, -1, -1, -1, -1, -1, -1

.section .text
.global _start

_start:
	
	MOV R0, #6
	MOV R6, #0x4
	LDR R1, =fibo_cache
	
	BL fibo
	B end
	
fibo:
	STMFD SP!, {R0, LR}
	MUL R7, R0, R6 // R7 = R0 * 0x4
	LDR R2, [R1, R7] // R2 = R1[R0]
	
	CMP R2, #-1 // check if uninitialized
	BNE done // if initialized, return R1[R0]
	
	CMP R0, #1 // base case, n <= 1
	MUL R7, R0, R6 // R7 = R0 * 0x4
	STRLE R0, [R1, R7] // R1[R0] = R0
	BLE done
	
	MOV R8, R0 // store n for mem[n] = fibo(n-1) + fibo(n-2)
	STMFD SP!, {R8}
	
	SUB R0, R0, #1 // fibo(n-1)
	BL fibo
	MOV R4, R3
	
	SUB R0, R0, #1 // fibo(n-2)
	BL fibo
	
	ADD R5, R4, R3 // fibo(n-1) + fibo(n-2)
	LDMFD SP!, {R8}
	MUL R7, R8, R6 // R7 = R8 * 0x4
	STR R5, [R1, R7] // mem[n] = fibo(n-1) + fibo(n-2)
	
	B done

done: // return mem[n], R3 = mem[n]
	LDMFD SP!, {R0, LR}
	MUL R7, R0, R6 // R7 = R0 * 0x4
	LDR R3, [R1, R7] // return (R3 = R1[R0]), result stored in R3
	MOV PC, LR
	
end:
