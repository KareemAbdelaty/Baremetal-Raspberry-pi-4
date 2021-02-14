//author Kareem Abdelaty
//assignment1b
define(x_val,x19)//defining register x19 as x_val
define(y_val,x20)//defining register x20 as y_val
define(max,x21)//defining register x21 as max
msg:    .string "the value of x is %d the value of y is %d the maxvalue is %d \n"//setup sentence for printing
	.balign 4	//alligning words
	.global main	// setting main as global
main:
	stp x29, x30, [sp, -16]!            // Save FP and LR to stack
        mov x29, sp				// Update FP to the current SP
	mov x_val, -10//setting x_val
	mov y_val, 0//setting the yval
	mov max, -5000 //setting max to a very small number so that if that largest y is negative it would still be recorded
	mov x22, -2//var for the equation
	mov x23, -22//var for the equation
	mov x24, 11//var for the equation
	mov x25, 57//var for the equation
	b test//test for the while loops condition
loop:
	madd x26, x24, x_val, x25 //value of 11x +57
	mul x27, x_val, x_val // x squared
	mul x28, x23, x27// -22x^2
	mul x27, x27, x_val//x^3
	madd x27, x27, x22, x26// -2x^3 +11x +57
	add x20, x27, x28// -2x^3 -22x^2 +11x+57 which is 20
	cmp y_val, max //compare y_val to max
	b.gt change_max //jump to change max if y is greater than max
continueloop:
	adrp x0, msg	// Set high-order bits of the 1st argument (format string)
	add x0, x0, :lo12:msg	// Set 1st argument (12 lower-order bits)
	mov x1, x_val	//pass x_val ass a parameter to printf
	mov x2, y_val	//pass  y_val as a parameter to printf
	mov x3, max	//pass the max number as a parameter to printf
	bl printf	//print the sentence
	add x_val, x_val,1	//increment x_var by one
test: 
	cmp x_val,5 //compare x_var to 5
	b.lt loop //if x_val is less than 5 go restart the loop
break:
end:
	ldp 	x29, x30, [sp], 16	// Restore FP and LR from stack
	ret				// Return to caller (OS)

change_max:
	mov max,y_val //set max equal to y_val
	b continueloop	// go back to the loo[
   	
