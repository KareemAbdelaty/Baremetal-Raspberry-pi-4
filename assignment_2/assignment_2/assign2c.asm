//By Kareem Abdelaty
//assignment2a
define(multiplic,w19) 						//define multiplicand as 32 bit register w19
define(multip,w20) 						       // define multiplier as 32 bit register w20
define(produc,w21) 						      // define product as 32 bit register w21
define(i,w22)							     //define the counter for the for loop as i the 32 bit register w22
define(negative,w23)						    //define the flag for wether multiplier is negative 32 bit register w23 named as negative
define(resul,x24) 						   // define the result as 64bit register x25 named result
define(temp1,x25) 						  // define 64bit register x25 as temp1
define(temp2,x26)						 // define 64bit  register x26 as temp2
vals:   .string "multiplier = 0x%08x (%d)  multiplicand = 0x%08x (%d)\n\n" 	//first sentence to be printed
vals2:  .string "product = 0x%08x  multiplier = 0x%08x\n"	//second sentence to be printed
vals3: 	.string "64-bit result = 0x%016lx (%ld)\n"		//third sentence to be printed
	.balign 4 
	.global main
main:
	stp x29, x30, [sp,-16]!                         // Save FP and LR to stack
	mov x29 ,sp                                     // Update FP to the current SP
	mov multiplic,-252645136			        //setting the multiplicand 
	mov multip,-256					//setting the multiplier
	mov produc,0					//initialising the product register to zero
	adrp x0,vals					//Set high-order bits of the base string (format string)
	add x0,x0,:lo12:vals				// Set base string (12 lower-order bits)
	mov w2,multip					// passing parameters to printf
	mov w1,multip					// passing parameters to printf
	mov w3,multiplic				// passing parameters to printf
	mov w4,multiplic				// passing parameters to printf
	bl  printf					// invoking printf
	cmp multip,0					//comparing multiply to zero 
	b.gt positive					// if it is greater than zero jump to postive
	mov negative,1					//else set negative to true
continue:
	mov i,0						//initilaize counter for for loop at zero
forloop:
	mov w27,0x1					//setting bitmask to 0x1
	and w28,w27,multip				//applying the mask to the multiply
	cmp w28,0					//if the result of the mask was zero then the lsb was a zero
	b.eq skipadd					//dont enter the if if the lsb was a zero
	add produc,produc,multiplic			//product = product + multiplicand
skipadd:
	asr multip,multip,w27				//arthmtic shift right by 1 for the multiplyer
	and w28,w27,produc				//apply the mask to product
	cmp w28,0					// if the lsb was a zero skip jump to else
	b.eq else
	orr multip,multip,0x80000000			//multiply = multiply|0x80000000
shiftprod:
	asr produc,produc,w27				// arthmtic shift product by 1 bit
	add i,i,1                                       //incrementing the counter
        cmp i,32                                        //checking if i has reached 32
        b.lt forloop
	cmp negative,1					//if negative is true jump to neg					
	b.eq neg
top:
	adrp x0,vals2					//Set high-order bits of the base string (format string)
        add x0,x0,:lo12:vals2				//Set base string (12 lower-order bits)
        mov w1,produc					//passing parameters to printf
        mov w2,multip					//passing parameter to printf
	bl  printf					//printing
	and temp1,x21,0xFFFFFFFF			//adding product + 0xffffffff
	lsl temp1,temp1,32				//shifting temp1 by 32 bits to the left
	and temp2,x20,0xFFFFFFFF			//storing multipliyer&0xffffffff in temp2
	add resul,temp1,temp2				// adding temp2 and temp1 and storing it in result
	adrp x0,vals3					//Set high-order bits of the base string (format string)
	add x0,x0,:lo12:vals3				//Set base string (12 lower-order bits)
	mov x1,resul					//passing parameter to printf
	mov x2,resul					//passing parameter to printf
	bl  printf					//printing
done:	
	ldp x29,x30,[sp],16				// Restore FP and LR from stack
	ret 						// Return to caller (OS)
 
	
	
positive:	
	mov negative,0					//if multiply is postive set negative to 0 (false)
	b continue					// branch back to continue
else:
	and multip,multip,0x7fffffff			//if lsb in product was not a 1 store multiply&0x7fffffff in multiply
	b shiftprod					// branch back to shiftprod
neg:
	sub produc,produc,multiplic		//if negative was set to 1 (true) subtract the multiplicand from the product and store it in the product
	b top						//branch back to top
