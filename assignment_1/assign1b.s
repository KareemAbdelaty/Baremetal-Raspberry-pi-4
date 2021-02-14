//author Kareem Abdelaty
//assignment1b
//defining register x19 as x19
//defining register x20 as x20
//defining register x21 as x21
msg:    .string "the value of x is %d the value of y is %d the maxvalue is %d \n"//setup sentence for printing
	.balign 4	//alligning words
	.global main	// setting main as global
main:
	stp x29, x30, [sp, -16]!            // Save FP and LR to stack
        mov x29, sp				// Update FP to the current SP
	mov x19, -10//setting x19
	mov x20, 0//setting the yval
	mov x21, -5000 //setting x21 to a very small number so that if that largest y is negative it would still be recorded
	mov x22, -2//var for the equation
	mov x23, -22//var for the equation
	mov x24, 11//var for the equation
	mov x25, 57//var for the equation
	b test//test for the while loops condition
loop:
	madd x26, x24, x19, x25 //value of 11x +57
	mul x27, x19, x19 // x squared
	mul x28, x23, x27// -22x^2
	mul x27, x27, x19//x^3
	madd x27, x27, x22, x26// -2x^3 +11x +57
	add x20, x27, x28// -2x^3 -22x^2 +11x+57 which is 20
	cmp x20, x21 //compare x20 to x21
	b.gt change_max //jump to change x21 if y is greater than x21
continueloop:
	adrp x0, msg	// Set high-order bits of the 1st argument (format string)
	add x0, x0, :lo12:msg	// Set 1st argument (12 lower-order bits)
	mov x1, x19	//pass x19 ass a parameter to printf
	mov x2, x20	//pass  x20 as a parameter to printf
	mov x3, x21	//pass the x21 number as a parameter to printf
	bl printf	//print the sentence
	add x19, x19,1	//increment x_var by one
test: 
	cmp x19,5 //compare x_var to 5
	b.lt loop //if x19 is less than 5 go restart the loop
break:
end:
	ldp 	x29, x30, [sp], 16	// Restore FP and LR from stack
	ret				// Return to caller (OS)

change_max:
	mov x21,x20 //set x21 equal to x20
	b continueloop	// go back to the loo[
   	
