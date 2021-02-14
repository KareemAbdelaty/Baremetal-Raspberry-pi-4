//Kareem Abdelaty 30075331
//assign3
				// Loop counter
				// inner Loop counter
				// index for minimum number
				// holder for number being switched
				// Register for mem w24
				// Base address for integer array
sentence:.string  "v[%d]: %d\n"			//Sentence to be printed
msg:	.string	  "\nSorted array:\n"		//sorted array to be printed
	//equate definition
	size = 50				//Size of array
	f_r		= 16			// Frame record size
	int_size	= 4			// Size of integer
	int_arr_size	= int_size*size		// Size of integer array
	int_arr_off	= f_r			// Memory w24 for integer array (address of first element)
	// Amount of memory to be allocated & deallocated 
	mem_alloc	= -(f_r + int_arr_size) & -16
fp	.req 	x29				// Register Equate assembler directive. Alias for x29
lr	.req 	x30				// Register Equate assembler directive. Alias for x30

	.balign	4				// Instructions must be word aligned
	.global main				// Make "main" visible to the OS and start the execution
main:	stp 	fp, lr, [sp, mem_alloc]!	// Save FP and LR to stack
	mov 	fp, sp				// Update FP to the current SP
	mov	w19,0				// initialize loop counter to zero
	mov 	w24,0			// initialize w24 to zero
	add     x25, fp , f_r                // Calculate the memory w24 to access the first element
	add     x25, x25, int_arr_size
forloop:
	bl	rand				// call the rand function
	and	w0,w0,0xff			//mod 256
	mov	w26,w0				//w23 storage of generated value
	str	w26,[x25 , w24,SXTW]		//store generated random number in memory
	add   	w24,w24,int_size		//increment w24
	adrp	x0,sentence			//passing argument to print f
	add     x0,x0,:lo12:sentence		//passing arrgument to printf
	mov	w1,w19				//passing w19 as a parameter to printf
	mov	w2,w26				//passing the v[w19] as a paramter to printf
	bl	printf				//call printf
	add	w19,w19,1				//incrementt counter
	cmp	w19,size				//check if loop completed
	b.lt	forloop
break:
	mov	w19,0				//reset w19 to 0
	mov	w24,int_size			//reset w24 to 4
forloop2:
	mov	w21,w19				//set w21 = w19 
	add	w20,w19,1				//set w20 to w19 +1
forloop3:
	mul	w28,w21,w24			//calculating location of v[w21]
	ldr	w27,[x25,w28,SXTW]		//load the value stored at v[w21]
	mul    w28,w20,w24                     //calculating location of v[w20]
	ldr	w26,[x25,w28,SXTW]		//load the value stored at v[w20]
	cmp	w26,w27				// If v[w20] < v[w21]
	b.lt	swap
continue:
	add w20,w20,1                               //increment w20
        cmp w20,size                              //check if end of loop
        b.lt   forloop3
	mul    W28,W21,W24                     //calculating location of v[w21]
	ldr w23,[x25,W28,SXTW]			//load the value stored at v[w21]
	mul    W28,W19,W24                     //calculating location of v[w19]
	ldr w26,[x25,W28,SXTW]  			//load the value stored at v[w19]
	mul    W28,W21,W24                     //calculating location of v[w21]
	str w26,[x25,W28,SXTW]			//store the value stored at v[w21]
	mul    W28,W19,W24                     //calculating location of v[w19]
	str w23,[x25,W28,SXTW]           	//store w23 at v[w19]
	add w19,w19,1				//increment w19
	cmp w19,size-1				//check if end of forloop2
	b.lt	forloop2
	adrp    x0,msg                     	//passing argument to print f
        add     x0,x0,:lo12:msg            	//passing arrgument to printf
	bl	printf				//call printf
	mov w19,0					//reset w19 to 0
forloop4:
	mul    W28,W19,W24	                 //calculating location of v[w19]
	ldr w26,[x25,W28,SXTW]	          	 //load the value stored at v[w19]
	adrp    x0,sentence                     //passing argument to print f
        add     x0,x0,:lo12:sentence            //passing arrgument to printf
        mov     w1,w19                            //passing w19 as a parameter to printf
        mov     w2,w26                          //passing the v[w19] as a paramter to printf
	bl      printf                          //call printf
	add w19,w19,1				//increment w19
	cmp w19,size				//check for end of forloop4
	b.lt forloop4
end:	
	ldp 	fp, lr, [sp], -mem_alloc	// Restore FP and LR
	ret					// Return to caller (OS)
	
swap:						//jump here if v[w20] < v[w21]
	mov w21,w20
	b continue 
	

