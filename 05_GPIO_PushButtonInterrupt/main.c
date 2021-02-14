// This program sets up GPIO pin 17 as an input pin, and sets it to generate
// an interrupt whenever a rising edge is detected. The pin is assumed to
// be connected to a push button switch on a breadboard. When the button is
// pushed, a 3.3V level will be applied to the pin. The pin should otherwise
// be pulled low with a pull-down resistor of 10K Ohms.

// Include files
#include "uart.h"
#include "sysreg.h"
#include "gpio.h"
#include "gic.h"


// Function prototypes
void init_GPIO17_to_risingEdgeInterrupt();

// Declare a global shared variable
unsigned int sharedValue;



////////////////////////////////////////////////////////////////////////////////
//
//  Function:       main
//
//  Arguments:      none
//
//  Returns:        void
//
//  Description:    This function first prints out the values of some system
//                  registers for diagnostic purposes. It then initializes
//                  GPIO pin 17 to be an input pin that generates an interrupt
//                  (IRQ exception) whenever a rising edge occurs on the pin.
//                  The function then goes into an infinite loop, where the
//                  shared global variable is continually checked. If the
//                  interrupt service routine changes the shared variable,
//                  then this is detected in the loop, and the current value
//                  is printed out.
//
////////////////////////////////////////////////////////////////////////////////

void main()
{
    unsigned int localValue, value, el, i;

    
    // Set up the UART serial port
    uart_init();

    // Print out initial values before setting GIC, etc.
    uart_puts("Initial Values:\n");
    
    // Query the current exception level
    el = getCurrentEL();
    
    // Print out the exception level
    uart_puts("  Exception level:  0x");
    uart_puthex(el);
    uart_puts("\n");
    
    // Get the SPSel value
    value = getSPSel();
    
    // Print out the SPSel value
    uart_puts("  SPSel:  0x");
    uart_puthex(value);
    uart_puts("\n");
        
    // Query the current DAIF flag values
    value = getDAIF();
    
    // Print out the DAIF flag values
    uart_puts("  DAIF flags:  0x");
    uart_puthex(value);
    uart_puts("\n");

    // Print out initial values the GPREN0 register (rising edge interrupt
    // enable register)
    value = *GPREN0;
    uart_puts("  GPREN0:  0x");
    uart_puthex(value);
    uart_puts("\n");
    

    // Initialize the sharedValue global variable and
    // and set the local variable to be same value
    localValue = sharedValue = 0;
    

    // Set and print out new values
    uart_puts("\nResetting to new values:\n");

    // Set up GPIO pin #17 to input and so that it triggers
    // an interrupt when a rising edge is detected
    init_GPIO17_to_risingEdgeInterrupt();
    
    // Enable IRQ Exceptions on the CPU core
    enableIRQ();
    
    // Query the current DAIF flag values
    value = getDAIF();
    
    // Print out the DAIF flag values
    uart_puts("  DAIF flags:  0x");
    uart_puthex(value);
    uart_puts("\n");

    // Print out new value of the GPREN0 register (rising
    // edge interrupt enable register)
    uart_puts("  GPREN0:  0x");
    value = *GPREN0;
    uart_puthex(value);
    uart_puts("\n\n");

    
    // Set up the Generic Interrupt Controller

    // First set all interrupts to the highest priority (0x00).
    // Each register holds the priorities for 4 interrupts each,
    // so we are setting 64 interrupts in total (numbered 0 - 63).
    for (i = 0; i < 16; i++) {
      *(GIC_GICD_IPRIORITYR + (i * 4)) = 0x00000000;
    }

    // Set supported SPIs targets to CPU 0 only (0x01, or 0b00000001).
    // Each register holds the targets for 4 interrupts each, so
    // we are setting 32 interrupts in total (numbered 32 - 63)
    for (i = 8; i < 16; i++) {
      *(GIC_GICD_ITARGETSR + (i * 4)) = 0x01010101;
    }

    // Set PPIs and supported SPIs to be edge-triggered and using
    // the 1-N model (0b11).
    // Each register holds the configuration for 16 interrupts each,
    // so we are are setting 48 interrupts in total (numbered 16 - 63).
    // Interrupts 0 - 15 (SGIs) are read-only (default to edge-triggered,
    // N-N model).
    for (i = 1; i < 4; i++) {
      *(GIC_GICD_ICFGR + (i * 4)) = 0xFFFFFFFF;
    }

    // Enable Bank 0 GPIO interrupts in the GIC.
    // Bit 17 in GICD_ISENABLER1 is for Bank 0 (pins 0 - 27)
    uart_puts("Enabling Bank 0 GPIO interrupts (pins 0 - 27) in GIC:\n");
    *(GIC_GICD_ISENABLER + (1 * 4)) = 0x00020000;

    // Print out enabled interrupts
    for (i = 0; i < 2; i++) {
      value = *(GIC_GICD_ISENABLER + (i * 4));
      uart_puts("  0x");
      uart_puthex(value);
      uart_puts("\n");
    }
    uart_puts("\n");

    // If in EL3 (secure-code), globally enable both Group 0 and Group 1
    // forwarding from the GICD to a GICC.
    if (el == 0x3) {
      *GIC_GICD_CTLR = 0x3;
      uart_puts("Enabling GIC forwarding of Group 0 and 1 interrupts.\n");
    } else {
      // Globally enable forwarding of Group 1 (non-secure) interrupts only
      // from the GICD to the GICC if in EL0, EL1, or EL2 (non-secure code).
      *GIC_GICD_CTLR = 0x1;
      uart_puts("Enabling GIC forwarding of Group 1 interrupts.\n");
    }
    value = *GIC_GICD_CTLR;
    uart_puts("  GICD_CTLR:  0x");
    uart_puthex(value);
    uart_puts("\n\n");


    

    // Print out a message to the console
    uart_puts("\nInfinite loop starting:\n");
    
    // Loop forever, waiting for interrupts to change the shared value
    while (1) {
        // Check to see if the shared value was changed by an interrupt
	if (localValue != sharedValue) {
	    // Update the local variable
	    localValue = sharedValue;

	    // Print out the shared value
	    uart_puts("\nsharedValue is:  ");
	    uart_puthex(sharedValue);
	    uart_puts("\n");
        }

        // Delay a little using a busy loop
        value = 0x0000FFFF;
    	while (value--) {
      	    asm volatile("nop");
    	}
    }
}



////////////////////////////////////////////////////////////////////////////////
//
//  Function:       init_GPIO17_to_risingEdgeInterrupt
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
//                  GPIO pin 17 is also set to trigger an interrupt on a
//                  rising edge, and GPIO interrupts are enabled on the
//                  interrupt controller.
//
////////////////////////////////////////////////////////////////////////////////

void init_GPIO17_to_risingEdgeInterrupt()
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

    // Set pin 17 to so that it generates an interrupt on a rising edge.
    // We do so by setting bit 17 in the GPIO Rising Edge Detect Enable
    // Register 0 to a 1 value (p. 97 in the Broadcom manual).
    *GPREN0 = (0x1 << 17);
}
