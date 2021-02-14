//By Kareem Abdelaty
//assignment2b
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
	mov w19, 522133279			        //setting the multiplicand 
	mov w20, 200					//setting the multiplier
	mov w21,0					//initialising the product register to zero
	adrp x0,vals					//Set high-order bits of the base string (format string)
	add x0,x0,:lo12:vals				// Set base string (12 lower-order bits)
	mov w2,w20					// passing parameters to printf
	mov w1,w20					// passing parameters to printf
	mov w3,w19				// passing parameters to printf
	mov w4,w19				// passing parameters to printf
	bl  printf					// invoking printf
	cmp w20,0					//comparing multiply to zero 
	b.gt positive					// if it is greater than zero jump to postive
	mov w23,1					//else set w23 to true
continue:
	mov w22,0						//initilaize counter for for loop at zero
forloop:
	mov w27,0x1					//setting bitmask to 0x1
	and w28,w27,w20				//applying the mask to the multiply
	cmp w28,0					//if the result of the mask was zero then the lsb was a zero
	b.eq skipadd					//dont enter the if if the lsb was a zero
	add w21,w21,w19			//product = product + multiplicand
skipadd:
	asr w20,w20,w27				//arthmtic shift right by 1 for the multiplyer
	and w28,w27,w21				//apply the mask to product
	cmp w28,0					// if the lsb was a zero skip jump to else
	b.eq else
	orr w20,w20,0x80000000			//multiply = multiply|0x80000000
shiftprod:
	asr w21,w21,w27				// arthmtic shift product by 1 bit
	add w22,w22,1                                       //incrementing the counter
        cmp w22,32                                        //checking if w22 has reached 32
        b.lt forloop
	cmp w23,1					//if w23 is true jump to neg					
	b.eq neg
top:
	adrp x0,vals2					//Set high-order bits of the base string (format string)
        add x0,x0,:lo12:vals2				//Set base string (12 lower-order bits)
        mov w1,w21					//passing parameters to printf
        mov w2,w20					//passing parameter to printf
	bl  printf					//printing
	and x25,x21,0xFFFFFFFF			//adding product + 0xffffffff
	lsl x25,x25,32				//shifting x25 by 32 bits to the left
	and x26,x20,0xFFFFFFFF			//storing multipliyer&0xffffffff in x26
	add x24,x25,x26				// adding x26 and x25 and storing it in result
	adrp x0,vals3					//Set high-order bits of the base string (format string)
	add x0,x0,:lo12:vals3				//Set base string (12 lower-order bits)
	mov x1,x24					//passing parameter to printf
	mov x2,x24					//passing parameter to printf
	bl  printf					//printing
done:	
	ldp x29,x30,[sp],16				// Restore FP and LR from stack
	ret 						// Return to caller (OS)
 
	
	
positive:	
	mov w23,0					//if multiply is postive set w23 to 0 (false)
	b continue					// branch back to continue
else:
	and w20,w20,0x7fffffff			//if lsb in product was not a 1 store multiply&0x7fffffff in multiply
	b shiftprod					// branch back to shiftprod
neg:
	sub w21,w21,w19		//if w23 was set to 1 (true) subtract the multiplicand from the product and store it in the product
	b top						//branch back to top
