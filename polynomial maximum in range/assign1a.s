// By Kareem Abdelaty
//Assignment1a.s
vals:   .string "x is %d y is %d and maxvalue is %d \n"// sentence to be printed
	.balign 4 
	.global main
main: 
	stp x29, x30, [sp,-16]!
	mov x29 ,sp
	mov x19 ,-10 // this is the x variable which will also be used as the test condition for the loop
	mov x20 ,0 // this is the y variable
	mov x21 ,-5000 // this the current maximum. it is set to a very low number so even if a the highest y is negative it will still be recorded
	mov x24 ,-2// register of value 02
	mov x25 ,-22// register of value -22
	mov x26 , 11//register of value 11

top:   
	 cmp x19 ,5 // checking if x is bigger than 4
	b.ge done//if x is bigger than 4 end go to the end
	mul x22 ,x19,x19//value of x^2
	mul x23 ,x22,x25//value of -22x^2
	mul x22,x22,x19//value of x^3
	mul x22,x22,x24//value of -2x^3
	mul x24,x19,x26//value of 11x
	add x20,x22,x23//adding -2x^3 +-22x^2
	add x20,x20,x24//adding 11x to the contents of the register
	add x20,x20,57//adding 57 to the contents of the register
	cmp x20,x21 // checking if there is a new maximum
	b.lt next //if not goto next
	mov x21,x20 // if there is a new maximum store it in x21
next: // label to go to if there is no new maximum

arg:	adrp x0,vals
	add x0,x0,:lo12:vals
	mov x1,x19//adding x as an argument to the printf statment
	mov x2,x20//adding the y value as an argument to the printf statment
	mov x3,x21 //adding the max value as an argument to printf statment
	add x19,x19,1//incrementing x by one

print:	bl printf//printing the output every loop
	b top //end of loop
done:
	ldp x29,x30,[sp],16
	ret 
 
