@ ARM Assembly - exercise 4
@ Group Number :

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	@ load values
	mov r0, #3
	
	@ Write YOUR CODE HERE
	@ if (i>5) f = 70;
	@ else if (i>3) f=55;
	@ else f = 30;
	@ i  in r0
	@ Put f to r5
	@ Hint : Use MOV instruction
	@ MOV r5,#70 makes r5=70


	@ ---------------------
	@ Compare r0 and 5
	cmp r0 , #5
	@ If r0 > 5 then link to label1 branch
	bgt label1 
	@ Compare r0 and 3
	cmp r0 , #3
	@ If r0 > 3 then link to label2 branch
	bgt label2
	@ Else set r5 as 30
	mov r5 , #30
	@ unconditional link to branch labelled exit
	b exit

	@ labe1 branch
	label1: mov r5 , #70 @ r5 = 70
	@ unconditional link to branch labelled exit
	b exit

	@ labe2 branch
	label2: mov r5 , #55 @ r5 = 55
	@ unconditional link to branch labelled exit
	b exit

	@ exit branch
	exit : 
	@ ---------------------
	
	
	@ load aguments and print
	ldr r0, =format
	mov r1, r5
	bl printf

	@ stack handling (pop lr from the stack) and return
	ldr lr, [sp, #0]
	add sp, sp, #4
	mov pc, lr

	.data	@ data memory
format: .asciz "The Answer is %d (Expect 30 if correct)\n"

