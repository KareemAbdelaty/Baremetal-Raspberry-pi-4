-//Kareem Abdelaty
//30075331
//assignmet 4
#include "gpio.h"
#include "systemtimer.h"
#include "framebuffer.h"
#define BUTTON_START  0x00000008
#define BUTTON_UP     0x00000010
#define BUTTON_DOWN   0x00000020
#define BUTTON_LEFT   0x00000040
#define BUTTON_RIGHT  0x00000080


void disable(register volatile unsigned int *reg,unsigned int pin);
unsigned int getPinValue(int a);
void setPinOutput(register volatile unsigned int *reg,unsigned int pin);
void setPinInput(register volatile unsigned int *reg,unsigned int pin);
void set_GPIOPin(int pin);
void clear_GPIOPin(pin);
unsigned short get_SNES();
void move(int m[12][16],int direction,int xpos,int ypos);
////////////////////////////////////////////////////////////////////////////////
//
//  Function:       main
//
//  Arguments:      none
//
//  Returns:        void
//
//  Description:   
//
////////////////////////////////////////////////////////////////////////////////
void main(){
	//intialize data and currentState
    unsigned short data, currentState = 0xFFFF;
	//intialize maze from assignmet sheet 0 represents and empty road, 1 represents a wall, 2 represents the starting position
	//and the postion of the player after the game starts, and 3 represnts the endpostion
	int maze[12][16] = 
	{{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
	{1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
    {2, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1}, 
	{1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1},
    {1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1},
    {1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1},
    {1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1}, 
	{1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1},
    {1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 3},
    {1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1}, 
	{1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1},
    {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};
	//starting xpos
	int xpos = 0;
	//starting ypos
	int ypos = 2;
	//set pins 9 and 11 to output and 10 to to input
	setPinOutput(*GPFSEL0,27);
	setPinOutput(*GPFSEL1,3);
	setPinInput(*GPFSEL1,0);
	//disable pull up/ down resistors for pins 9,10,11
	disable(*GPPUPPDN0,18);
	disable(*GPPUPPDN0,20);
	disable(*GPPUPPDN0,22);
	//clear pins 9 and set pin 11 
	clear_GPIOPin(9);
	set_GPIOPin(11);
	//Initialize frame buffer and mailbox datastructure
	initFrameBuffer();
	// Display initial frame buffer with no player present
	displayFrameBuffer(maze,0);
	//variable the keeps track if the game has started
	int gamestarted =0;
	while(1){
		data = get_SNES();
		if (data != currentState) {
			//if the game hasnt started and start is pressed start the game
			if((data== BUTTON_START)&&(gamestarted !=1)){
				gamestarted = 1;
				currentState = data;
				//display the player
				displayFrameBuffer(maze,1);
			}
			//check for the direction of movment,move the player and update the screen
			else if((data == BUTTON_UP)&&(gamestarted==1)){
				move(maze,1,xpos,ypos);
				displayFrameBuffer(maze,1);
				currentState = data;
			}
			else if((data == BUTTON_DOWN)&&(gamestarted==1)){
				move(maze,2,xpos,ypos);
				displayFrameBuffer(maze,1);
				currentState = data;
			}
			else if((data == BUTTON_RIGHT)&&(gamestarted==1)){
				move(maze,3,xpos,ypos);
				displayFrameBuffer(maze,1);
				currentState = data;
			}
			else if((data == BUTTON_LEFT)&&(gamestarted==1)){
				move(maze,4,xpos,ypos);
				displayFrameBuffer(maze,1);
				currentState = data;
			}
			//check if the player is in a wining position by checking if the end postion in the maze contains a 2 
			if(maze[8][15] == 2){
				//end the game
				gamestarted =0;
				//reset xpos,ypos
				xpos = 0;
				ypos =2;
				//display winning screen
				displayFrameBuffer(maze,2);
				//reset maze 
					int maze[12][16] = 
					{{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
					{1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
					{2, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1}, 
					{1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1},
					{1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1},
					{1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1},
					{1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1}, 
					{1, 0, 1, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1},
					{1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 3},
					{1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1}, 
					{1, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1},
					{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};				
							
		}
			
			// Delay 1/30th of a second
			microsecond_delay(33333);
		

		
	}
}
////////////////////////////////////////////////////////////////////////////////
//
//  Function:       disable
//
//  Arguments:      A pointer to a register reg, and bitfieled of pin to be set
//
//  Returns:        void
//
//  Description:    This function disable PullUp/PullDown resistors for a specfied pin. You shold take care while
//					passing parameters to the function because 
//					at this point the function does not check for incorrect parameters
//
////////////////////////////////////////////////////////////////////////////////

void disable(register volatile unsigned int *reg,unsigned int pin){
	register volatile unsigned int r;
	// Get the current bit pattern of the GPPUPPDN/1 register
    r = *reg;

    // Zero out bit pattern,
    // The bit pattern 00 disables pullups/pulldowns.
    r &= ~(0x3 << pin);

    // Write the modified bit pattern back to the
    // GPPUPPDN/1 register
    *reg = r;
}
////////////////////////////////////////////////////////////////////////////////
//
//  Function:       getPinValue
//
//  Arguments:      Either the bitfield for A or the bitfield for B
//
//  Returns:        1 if the pin level is high, and 0 if the pin level is low.
//
//  Description:    This function gets the current value of a pin 
//
////////////////////////////////////////////////////////////////////////////////
unsigned int getPinValue(int a)
{
    register unsigned int r;
	  
	  
    // Get the current contents of the GPIO Pin Level Register 0
    r = *GPLEV0;
	
    // Isolate pin, and return its value (a 0 if low, or a 1 if high)
    return ((r >> a) & 0x1);
}
////////////////////////////////////////////////////////////////////////////////
//
//  Function:       setPinOutput
//
//  Arguments:      A pointer to a register reg, and bitfieled of pin to be set
//
//  Returns:        void
//
//  Description:    This function sets the GPIO output pin
//                  to an output pin. You shold take care while
//					passing parameters to the function because 
//					at this point the function does not check for incorrect parameters
//
////////////////////////////////////////////////////////////////////////////////


void setPinOutput(register volatile unsigned int *reg,unsigned int pin){
	register volatile unsigned int r;
	// Get the current contents of the GPIO Function Select Register
    r = *reg;

    // Clear bits of the passed bitfield. 
    r &= ~(0x7 << pin);

    // Set the field to 001, which sets pin to an output pin.
    r |= (0x1 << pin);

    // Write the modified bit pattern back to the
    // GPIO Function Select Register 
    *reg = r;
}


////////////////////////////////////////////////////////////////////////////////
//
//  Function:       setPininput
//
//  Arguments:      A pointer to a register reg, and bitfieled of pin to be set
//
//  Returns:        void
//
//  Description:    This function sets a GPIO pin
//                  to an input pin. You shold take care while
//					passing parameters to the function because 
//					at this point the function does not check for incorrect parameters
//
////////////////////////////////////////////////////////////////////////////////


void setPinInput(register volatile unsigned int *reg,unsigned int pin){
	register volatile unsigned int r;
	// Get the current contents of the GPIO Function Select Register
    r = *reg;

    // Clear bits of the passed bitfield. 
    r &= ~(0x7 << pin);

    // Set the field to 001, which sets pin to an output pin.
    r |= (0x0 << pin);

    // Write the modified bit pattern back to the
    // GPIO Function Select Register 
    *reg = r;
	}
	
////////////////////////////////////////////////////////////////////////////////
//
//  Function:       set_GPIOPin(int pin)
//
//  Arguments:      A pin to bet set
//
//  Returns:        void
//
//  Description:    This function sets the GPIO output pin provided
//                  to a 1 (high) level.
//
////////////////////////////////////////////////////////////////////////////////

void set_GPIOPin(int pin)
{
    register unsigned int r;
	  
    // Put a 1 into the SET11 field of the GPIO Pin Output Set Register 0
    r = (0x1 << pin);
    *GPSET0 = r;
}

////////////////////////////////////////////////////////////////////////////////
//
//  Function:       clear_GPIOPin(int pin)
//
//  Arguments:      A pin to be cleared
//
//  Returns:        void
//
//  Description:    This function clears the GPIO output pin provided
//                  to a 0 (low) level.
//
////////////////////////////////////////////////////////////////////////////////

void clear_GPIOPin(int pin)
{
    register unsigned int r;
	  
    // Put a 1 into the CLR field of the GPIO Pin Output Clear Register 0
    r = (0x1 << pin);
    *GPCLR0 = r;
}
////////////////////////////////////////////////////////////////////////////////
//
//  Function:       get_SNES
//
//  Arguments:      none
//
//  Returns:        A short integer with the button presses encoded with 16
//                  bits. 1 means pressed, and 0 means unpressed. Bit 0 is
//                  button B, Bit 1 is button Y, etc. up to Bit 11, which is
//                  button R. Bits 12-15 are always 0.
//
//  Description:    This function samples the button presses on the SNES
//                  controller, and returns an encoding of these in a 16-bit
//                  integer. We assume that the CLOCK output is already high,
//                  and set the LATCH output to high for 12 microseconds. This
//                  causes the controller to latch the values of the button
//                  presses into its internal register. We then clock this data
//                  to the CPU over the DATA line in a serial fashion, by
//                  pulsing the CLOCK line low 16 times. We read the data on
//                  the falling edge of the clock. The rising edge of the clock
//                  causes the controller to output the next bit of serial data
//                  to be place on the DATA line. The clock cycle is 12
//                  microseconds long, so the clock is low for 6 microseconds,
//                  and then high for 6 microseconds. 
//
////////////////////////////////////////////////////////////////////////////////

unsigned short get_SNES()
{
    int i;
    unsigned short data = 0;
    unsigned int value;
	
	
    // Set LATCH to high for 12 microseconds. This causes the controller to
    // latch the values of button presses into its internal register. The
    // first serial bit also becomes available on the DATA line.
    set_GPIO(9);
    microsecond_delay(12);
    clear_GPIO9();
	
    // Output 16 clock pulses, and read 16 bits of serial data
    for (i = 0; i < 16; i++) {
	// Delay 6 microseconds (half a cycle)
	microsecond_delay(6);
		
	// Clear the CLOCK line (creates a falling edge)
	clear_GPIO(11);
		
	// Read the value on the input DATA line
	value = getPinValue(10);
		
	// Store the bit read. Note we convert a 0 (which indicates a button
	// press) to a 1 in the returned 16-bit integer. Unpressed buttons
	// will be encoded as a 0.
	if (value == 0) {
	    data |= (0x1 << i);
	}
		
	// Delay 6 microseconds (half a cycle)
	microsecond_delay(6);
		
	// Set the CLOCK to 1 (creates a rising edge). This causes the
	// controller to output the next bit, which we read half a
	// cycle later.
	set_GPIO(11);
    }
	
    // Return the encoded data
    return data;
}
////////////////////////////////////////////////////////////////////////////////
//
//  Function:       move
//
//  Arguments:      maze and direction to move the player, player xpos,player ypos
//
//  Returns:        void
//
//  Description:   checks if the direction of movment is valid(not a wall), and moves the player if it is valid.
//					if the player moves to a winning spot display player as green
//					redraws the screen
//
////////////////////////////////////////////////////////////////////////////////
void move(int m[12][16],int direction,int xpos,int ypos){
	//if moving up
	if(direction == 1){
		//if up direction is a free path
		if(m[ypos-1][x]==0){
			//move the player
			m[ypos-1][x]=2;
			//reset the old player postion to a free path
			m[ypos][x] =0;
			//update the player ypos
			ypos -=1;
		}
		
	}
	//if the direction is down
	else if(direction == 2){
		//if down direction is a free path
		if(m[ypos+1][x]==0){
			//move the player
			m[ypos+1][x]=2;
			//reset the old player postion to a free path
			m[ypos][x] =0;
			//update the player ypos
			ypos +=1;
		}
		
	}
	//move to the right
	else if(direction == 3){
		//if down direction is a free path
		if(m[ypos][x+1]==0){
			//move the player
			m[ypos][x+1]=2;
			//reset the old player postion to a free path
			m[ypos][x] =0;
			//update the player xpos
			xpos +=1;
		}
		
	}
	//move to the left
	else if(direction == 4){
		//check that the player is not at the start position
		if(xpos !=0){
			//if down direction is a free path
			if(m[ypos][x-1]==0){
				//move the player
				m[ypos][x-1]=2;
				//reset the old player postion to a free path
				m[ypos][x] =0;
				//update the player xpos
				xpos -=1;
			}
		}
		
	}
}

