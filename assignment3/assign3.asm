//Kareem Abdelaty 30075331
//assign3
define(i, 	w19)				// Loop counter
define(j, 	w20)				// inner Loop counter
define(min,    w21)				// index for minimum number
define(temp,	w23)				// holder for number being switched
define(offset,	w24)				// Register for mem offset
define(a_base, 	x25)				// Base address for integer array
sentence:.string  "v[%d]: %d\n"			//Sentence to be printed
msg:	.string	  "\nSorted array:\n"		//sorted array to be printed
	//equate definition
	size = 50				//Size of array
	f_r		= 16			// Frame record size
	int_size	= 4			// Size of integer
	int_arr_size	= int_size*size		// Size of integer array
	int_arr_off	= f_r			// Memory offset for integer array (address of first element)
	// Amount of memory to be allocated & deallocated 
	mem_alloc	= -(f_r + int_arr_size) & -16
fp	.req 	x29				// Register Equate assembler directive. Alias for x29
lr	.req 	x30				// Register Equate assembler directive. Alias for x30

	.balign	4				// Instructions must be word aligned
	.global main				// Make "main" visible to the OS and start the execution
main:	stp 	fp, lr, [sp, mem_alloc]!	// Save FP and LR to stack
	mov 	fp, sp				// Update FP to the current SP
	mov	i,0				// initialize loop counter to zero
	mov 	offset,0			// initialize offset to zero
	add     a_base, fp , f_r                // Calculate the memory offset to access the first element
	add     a_base, a_base, int_arr_size
forloop:
	bl	rand				// call the rand function
	and	w0,w0,0xff			//mod 256
	mov	w26,w0				//temp storage of generated value
	str	w26,[a_base , offset,SXTW]		//store generated random number in memory
	add   	offset,offset,int_size		//increment offset
	adrp	x0,sentence			//passing argument to print f
	add     x0,x0,:lo12:sentence		//passing arrgument to printf
	mov	w1,i				//passing i as a parameter to printf
	mov	w2,w26				//passing the v[i] as a paramter to printf
	bl	printf				//call printf
	add	i,i,1				//incrementt counter
	cmp	i,size				//check if loop completed
	b.lt	forloop
break:
	mov	i,0				//reset i to 0
	mov	offset,int_size			//reset offset to 4
forloop2:
	mov	min,i				//set min = i 
	add	j,i,1				//set j to i +1
forloop3:
	mul	w28,w21,w24			//calculating location of v[min]
	ldr	w27,[a_base,w28,SXTW]		//load the value stored at v[min]
	mul    w28,w20,w24                     //calculating location of v[j]
	ldr	w26,[a_base,w28,SXTW]		//load the value stored at v[j]
	cmp	w26,w27				// If v[j] < v[min]
	b.lt	swap
continue:
	add j,j,1                               //increment j
        cmp j,size                              //check if end of loop
        b.lt   forloop3
	mul    W28,W21,W24                     //calculating location of v[min]
	ldr temp,[a_base,W28,SXTW]			//load the value stored at v[min]
	mul    W28,W19,W24                     //calculating location of v[i]
	ldr w26,[a_base,W28,SXTW]  			//load the value stored at v[i]
	mul    W28,W21,W24                     //calculating location of v[min]
	str w26,[a_base,W28,SXTW]			//store the value stored at v[min]
	mul    W28,W19,W24                     //calculating location of v[i]
	str temp,[a_base,W28,SXTW]           	//store temp at v[i]
	add i,i,1				//increment i
	cmp i,size-1				//check if end of forloop2
	b.lt	forloop2
	adrp    x0,msg                     	//passing argument to print f
        add     x0,x0,:lo12:msg            	//passing arrgument to printf
	bl	printf				//call printf
	mov i,0					//reset i to 0
forloop4:
	mul    W28,W19,W24	                 //calculating location of v[i]
	ldr w26,[a_base,W28,SXTW]	          	 //load the value stored at v[i]
	adrp    x0,sentence                     //passing argument to print f
        add     x0,x0,:lo12:sentence            //passing arrgument to printf
        mov     w1,i                            //passing i as a parameter to printf
        mov     w2,w26                          //passing the v[i] as a paramter to printf
	bl      printf                          //call printf
	add i,i,1				//increment i
	cmp i,size				//check for end of forloop4
	b.lt forloop4
end:	
	ldp 	fp, lr, [sp], -mem_alloc	// Restore FP and LR
	ret					// Return to caller (OS)
	
swap:						//jump here if v[j] < v[min]
	mov min,j
	b continue 
	

