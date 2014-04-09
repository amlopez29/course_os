/*
 *
 * Harware Handler Interface  
 *
 */
#include "include/hw_handlers.h"
#include "include/mmap.h"

void init_vector_table(void) {

	/* Primary Vector Table */
	mmio_write(0x00, BRANCH_INSTRUCTION);
	mmio_write(0x04, BRANCH_INSTRUCTION);
	mmio_write(0x08, BRANCH_INSTRUCTION);
	mmio_write(0x0C, BRANCH_INSTRUCTION);
	mmio_write(0x10, BRANCH_INSTRUCTION);
	mmio_write(0x14, BRANCH_INSTRUCTION);
	mmio_write(0x18, BRANCH_INSTRUCTION);
	mmio_write(0x1C, BRANCH_INSTRUCTION);

	/* Secondary Vector Table */
	mmio_write(0x20, reset_handler);
	mmio_write(0x24, undef_instruction_handler);
	mmio_write(0x28, software_interrupt_handler);
	mmio_write(0x2C, prefetch_abort_handler);
	mmio_write(0x30, data_abort_handler);
	mmio_write(0x34, reserved_handler);
	mmio_write(0x38, irq_handler);
	mmio_write(0x3C, fiq_handler);
}


/* handlers */
void reset_handler(void){
	print_uart0("RESET HANDLER\n");
}

void undef_instruction_handler(void){
	print_uart0("UNDEFINED INSTRUCTION HANDLER\n");
}

void software_interrupt_handler(void){
	print_uart0("SOFTWARE INTERRUPT HANDLER\n");
}

void prefetch_abort_handler(void){
	print_uart0("PREFETCH ABORT HANDLER\n");
}

void data_abort_handler(void){
	print_uart0("DATA ABORT HANDLER\n");
}

void reserved_handler(void){
	print_uart0("RESERVED HANDLER\n");
}

void irq_handler(void){
	print_uart0("IRQ HANDLER\n");
	// disable interrupts
	disable_interrupt(ALL);
	// Save the address of the next instruction in the appropriate Link Register LR.
	asm volatile ("MOV lr, pc \n\t"	); 
	// Copy CPSR to the SPSR of new mode.
	int spsr;
	spsr = get_proc_status();
	// Change the mode by modifying bits in CPSR.
	
	// Fetch next instruction from the vector table.  
   	int interrupt_vector;
   	// handle_interrupt(interrupt_vector);

	// Leaving exception handler
	// Move the Link Register LR (minus an offset) to the PC.
	// Copy SPSR back to CPSR, this will automatically changes the mode back to the previous one.
	// Clear the interrupt disable flags (if they were set).
	enable_interrupt(ALL);
	// an IRQ handler returns from the interrupt by executing:
	// SUBS PC, R14_irq, #4
}

void fiq_handler(void){
	print_uart0("FIQ HANDLER\n");
// FIQ handler returns from the interrupt by executing:
// SUBS PC, R14_fiq, #4
}