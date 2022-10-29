@ ARM Assembly - exercise 5
@ Group Number :

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	
	@ Write YOUR CODE HERE
	
	@ j=0;
	@ for (i=0;i<10;i++)
	@ 		j+=i;	
	
	@ Put final j to r5



	@ ---------------------
	@ Set r5 as 0 (j)
	mov r5 , #0
	@ Set r0 as 0 (i)
	mov r0 , #0 

	@ Branch labelled loop
	loop :	cmp r0 , #10 @ Compare  r0 with 10
			beq exit @ If r0 = 10 then link to exit branch
			add r5 , r5 , r0 @ Else r5 = r5 + r0 
			add r0 , r0 , #1 @ r0++
			@ link to branch labelled loop
			b loop

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
format: .asciz "The Answer is %d (Expect 45 if correct)\n"

