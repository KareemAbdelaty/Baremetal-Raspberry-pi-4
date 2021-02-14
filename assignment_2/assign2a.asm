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
	mov multiplic,-16843010			//setting the multiplicand 
	mov multip,70				//setting the multiplier
	mov produc,0					//initialising the product register to zero
	adrp x0,vals					//
	add x0,x0,:lo12:vals
	mov w1,multip
	mov w2,multiplic
	bl  printf
	mov negative,1
	cmp multip,0
	b.gt positive
	mov negative,1
continue:
	mov i,0
forloop:
	mov w27,0x1
	and w28,w27,multip
	cmp w28,0
	b.eq skipadd
	add produc,produc,multiplic
skipadd:
	asr multip,multip,w27
	and w28,w27,produc
	cmp w28,0
	b.eq else
	and multip,multip,0x80000000
shiftprod:
	asr produc,produc,w27
	cmp multip,0
	b.lt neg
top:
	adrp x0,vals2
        add x0,x0,:lo12:vals2
        mov w1,produc
        mov w2,multip
	bl  printf	
	cmp i,32
	b.lt forloop
	and temp1,x21,0xFFFFFFFF
	lsl temp1,temp1,32
	and temp2,x20,0xFFFFFFFF
	add resul,temp1,temp2
	adrp x0,vals3
	add x0,x0,:lo12:vals3
	mov x1,resul
	mov x2,resul
	bl  printf
done:
	ldp x29,x30,[sp],16
	ret 
 
	
	
positive:	
	mov negative,0
	b continue
else:
	and multip,multip,0x7fffffff
	b shiftprod
neg:
	sub produc,produc,multip
	b top	
