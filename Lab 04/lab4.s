@ ARM Assembly Lab 4
	.text	@ instruction memory
	.global main
main:
	@ push  lr to the stack
	sub	sp, sp, #4
	str	lr, [sp, #0]
	

    @allocate stack for number of strings
	sub	sp, sp, #4
	@printf for number of strings
	ldr	r0, =formatr
	bl	printf
	@scanf for number of strings
	ldr	r0, =formats
	mov	r1, sp
	bl	scanf	@scanf("%s",sp)
    @copy number of strings from the stack to register r4
    ldr	r4, [sp , #0]
    @release stack (input)
	add	sp, sp, #4

    cmp r4 , #0 // Compare r4 with 0
    beq exit // If r4 == 0
    blt invalid // If r4 < 0

	
	mov r6 , #1 // index for the string
loop2:
		@allocate stack for string
		sub	sp, sp, #200
		@printf for string
		ldr	r0, =formatk
		mov r1 , r6
		bl	printf
		@scanf for string
		ldr	r0, =formatl
		mov	r1, sp
		bl	scanf	@scanf("%s",sp)


		@stringLen function call
		mov r0 , sp // Copy sp to r0
		bl	stringLen
		
		
		sub r5 , r1 , #1  // r5 = r1 - 1

	loop1: 
		add r2 , r5 , sp // r2 = r5 + sp
		ldrb	r1, [r2, #0] // r1 contains a character
		@ printf for character
		ldr	r0, =formatm 
		bl	printf

		sub r5 , r5 , #1 // r5 decrement by 1
		cmp r5 , #0 // Compare r5 with 0
		bge loop1 // if r5 >= 0 then loop

		@ printf for new line
		ldr	r0, =formatn
		bl	printf
		@release stack (input)
		add	sp, sp, #200

	add r6 , r6 , #1
	cmp r6 , r4  // r4 contains number of strings
	ble loop2 // if r3 less or equal to r4 then looping. Else exit


    b exit


	@ string length function
stringLen:
	@ Allocate stack for lr and store it
	sub	sp, sp, #4
	str	lr, [sp, #0]

	mov	r1, #0	@ length counter

loop:
	ldrb r2, [r0, #0] // load character to r2
	cmp	r2, #0 // 0 means null terminator
	beq	endLoop

	add	r1, r1, #1	@ count length
	add	r0, r0, #1	@ move to the next element in the char array
	b	loop

endLoop:
	@ r1 contain the length
	ldr	lr, [sp, #0]
	add	sp, sp, #4 // release stack
	mov	pc, lr // return



invalid:
    ldr	r0, =formati
	bl	printf
    b exit

exit:
    @ stack handling (pop lr from the stack) and return
    ldr	lr, [sp, #0]
	add	sp, sp, #4
	mov	pc, lr	

	.data	@ data memory
formatr: .asciz "Enter the number of strings :\n"
formats: .asciz "%d"
formati: .asciz "Invalid Number\n"
formatk: .asciz "Enter input string %d:\n"
formatl: .asciz " %[^\n]s"
formatm: .asciz "%c"
formatn: .asciz "\n"

