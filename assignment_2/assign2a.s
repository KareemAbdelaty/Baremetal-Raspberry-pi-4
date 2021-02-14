//By Kareem Abdelaty
//assignment2a
 						//define multiplicand as 32 bit register w19
 						       // define multiplier as 32 bit register w20
 						      // define product as 32 bit register w21
							     //define the counter for the for loop as w22 the 32 bit register w22
						    //define the flag for wether multiplier is w23 32 bit register w23 named as w23
 						   // define the result as 64bit register x25 named result
 						  // define 64bit register x25 as x25
						 // define 64bit  register x26 as x26
vals:   .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n" 	//first sentence to be printed
vals2:  .string "product = 0x%08x  multiplier = 0x%08x\n"	//second sentence to be printed
vals3: 	.string "64-bit result = 0x%016lx (%ld)\n"		//third sentence to be printed
	.balign 4 
	.global main
main:
	stp x29, x30, [sp,-16]!                         // Save FP and LR to stack
	mov x29 ,sp                                     // Update FP to the current SP
	mov w19,-16843010			//setting the multiplicand 
	mov w20,70				//setting the multiplier
	mov w21,0					//initialising the product register to zero
	adrp x0,vals					//
	add x0,x0,:lo12:vals
	mov w1,w20
	mov w2,w19
	bl  printf
	mov w23,1
	cmp w20,0
	b.gt positive
	mov w23,1
continue:
	mov w22,0
forloop:
	mov w27,0x1
	and w28,w27,w20
	cmp w28,0
	b.eq skipadd
	add w21,w21,w19
skipadd:
	asr w20,w20,w27
	and w28,w27,w21
	cmp w28,0
	b.eq else
	and w20,w20,0x80000000
shiftprod:
	asr w21,w21,w27
	cmp w20,0
	b.lt neg
top:
	adrp x0,vals2
        add x0,x0,:lo12:vals2
        mov w1,w21
        mov w2,w20
	bl  printf	
	cmp w22,32
	b.lt forloop
	and x25,x21,0xFFFFFFFF
	lsl x25,x25,32
	and x26,x20,0xFFFFFFFF
	add x24,x25,x26
	adrp x0,vals3
	add x0,x0,:lo12:vals3
	mov x1,x24
	mov x2,x24
	bl  printf
done:
	ldp x29,x30,[sp],16
	ret 
 
	
	
positive:	
	mov w23,0
	b continue
else:
	and w20,w20,0x7fffffff
	b shiftprod
neg:
	sub w21,w21,w20
	b top	
