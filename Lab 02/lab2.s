@ ARM Assembly - lab 2
@ Group Number :

	.text 	@ instruction memory
	.global main
main:
	@ stack handling, will discuss later
	@ push (store) lr to the stack
	sub sp, sp, #4
	str lr, [sp, #0]

	
	@ Write YOUR CODE HERE
	
	@	Sum = 0;
	@	for (i=0;i<10;i++){
	@			for(j=5;j<15;j++){
	@				if(i+j<10) sum+=i*2
	@				else sum+=(i&j);	
	@			}	
	@	} 
	@ Put final sum to r5



	@ ---------------------
	@ load values

	mov r5 , #0 @ sum = 0
	mov r1 , #0 @ i = 0
	
	@ Loop1 branch
	loop1 : 
			@ Set j as 5
			mov r2 , #5
			@ Compare i with 10
			cmp r1 , #10
			@ If i = 10 then link to exit branch
			beq exit

		@ Loop2 branch
		loop2 : 
				@ Compare i with 15
				cmp r2 , #15
				@ if i = 15 then link to outer_inc branch
				beq outer_inc

				add r3 , r1 , r2 @ r3 = i + j
				@ Compare r3 value with 10
				cmp r3 , #10 
				@ If r3 value < 10 link to branch labelled sum
				blt sum
				and r3 , r1 , r2 @ r3 = i & j
				add r5 , r5 , r3 @ sum += (i&j)
				@ link to inner_inc branch
				b inner_inc
			
	@ Sum branch
	sum : 	
			add r9 , r1 , r1 @ r9 = i*2 
			add r5 , r5 , r9 @ sum += i*2
			@ link to inner_inc branch
			b inner_inc

	@ outer_inc branch
	outer_inc : 
				add r1 , r1 , #1 @ r1++
				@ link to loop1 branch
				b loop1

	@ inner_inc branch
	inner_inc : 
				add r2 , r2 , #1 @ r2++
				@ link to loop1 branch
				b loop2

	@ exit branch
	exit:
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
format: .asciz "The Answer is %d (Expect 300 if correct)\n"

