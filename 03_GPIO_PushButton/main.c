// This program sets up GPIO pin 17 as an input pin, which is assumed to
// be connected to a push button switch on a breadboard. When the button is
// pushed, a 3.3V level should be applied to the pin. The pin should otherwise
// be pulled low with a pull-down resistor of 10K Ohms. The program polls this
// pin in an infinite loop, and writes its current level (low or high) to the
// console terminal.

// Include files
#include "uart.h"
#include "gpio.h"

// Function prototypes
void init_GPIO17_to_input();
unsigned int get_GPIO17();



////////////////////////////////////////////////////////////////////////////////
//
//  Function:       main
//
//  Arguments:      none
//
//  Returns:        void
//
//  Description:    This function initializes GPIO pin 17 to be an input pin
//                  without an internal pull-up or pull-down resistor. It then
//                  polls the pin an infinite loop, and prints out the current
//                  state (low or high) of the pin. We will use a push button
//                  switch on the bread board circuit connected to this pin.
//                  Be sure to use a pull-down (or pull-up) resistor on the pin.
//                  In other words, do not let the input pin float. Also be
//                  sure to use 3.3V (NOT 5V) to set the pin high.
//
////////////////////////////////////////////////////////////////////////////////

void main()
{
    register unsigned int r;


    // Set up the UART serial port
    uart_init();
    
    // Set up GPIO pin #17 for input
    init_GPIO17_to_input();
    
    // Print out a message to the console
    uart_puts("External Switch Program starting.\n");
    
    // Loop forever, polling pin 17 for its current level
    while (1) {
    	// Get the current value of pin 17
    	r = get_GPIO17();
    	
	// Determine the pin input level and print this to the console
	if (r == 0) {
	    uart_puts("Low\n");
	} else {
	    uart_puts("High\n");
	}
        
        // Delay a little using a busy loop
        r = 0x000FFFFF;
    	while (r--) {
      	    asm volatile("nop");
    	}
    }
}



////////////////////////////////////////////////////////////////////////////////
//
//  Function:       init_GPIO17_to_input
//
//  Arguments:      none
//
//  Returns:        void
//
//  Description:    This function sets GPIO pin 17 to an input pin without
//                  any internal pull-up or pull-down resistors. Note that
//                  a pull-down (or pull-up) resistor must be used externally
//                  on the bread board circuit connected to the pin. Be sure
//                  that the pin high level is 3.3V (definitely NOT 5V).
//
////////////////////////////////////////////////////////////////////////////////

void init_GPIO17_to_input()
{
    register unsigned int r;
    
    
    // Get the current contents of the GPIO Function Select Register 1
    r = *GPFSEL1;

    // Clear bits 21 - 23. This is the field FSEL17, which maps to GPIO pin 17.
    // We clear the bits by ANDing with a 000 bit pattern in the field. This
    // sets the pin to be an input pin
    r &= ~(0x7 << 21);

    // Write the modified bit pattern back to the
    // GPIO Function Select Register 1
    *GPFSEL1 = r;


    // Disable the pull-up/pull-down control line for GPIO pin 17.
    // Enabling and disabling pullups/pulldowns has changed with the
    // Pi 4, as shown below:

    // Get the current bit pattern of the GPPUPPDN1 register
    r = *GPPUPPDN1;

    // Zero out bits 2-3 in this bit pattern, since this maps to
    // GPIO pin 17. The bit pattern 00 disables pullups/pulldowns.
    r &= ~(0x3 << 2);

    // Write the modified bit pattern back to the
    // GPPUPPDN1 register
    *GPPUPPDN1 = r;
}



////////////////////////////////////////////////////////////////////////////////
//
//  Function:       get_GPIO17
//
//  Arguments:      none
//
//  Returns:        1 if the pin level is high, and 0 if the pin level is low.
//
//  Description:    This function gets the current value of pin 17.
//
////////////////////////////////////////////////////////////////////////////////

unsigned int get_GPIO17()
{
    register unsigned int r;
	  
	  
    // Get the current contents of the GPIO Pin Level Register 0
    r = *GPLEV0;
	  
    // Isolate pin 17, and return its value (a 0 if low, or a 1 if high)
    return ((r >> 17) & 0x1);
}
