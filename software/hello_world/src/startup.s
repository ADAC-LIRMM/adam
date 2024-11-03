/* Author: Soriano Theo; Felipe Alencar */
.global default_handler

/* Set up base addresses for ROM and RAM */
.word __ROM_BASE
.word __RAM_BASE

/* -------------------------------------------------------------------------- */
/* RESET HANDLER */

.section .text.reset_handler
.weak reset_handler
.type reset_handler, %function

reset_handler:

	# Maestro Registers Addresses
	la x1, 0x00008094 # MEM0
	la x2, 0x000080a4 # MEM1

	# Trigger Maestro Resume 
	li x6, 1 
	sw x6, 0(x1)
	sw x6, 0(x2)

	# Wait for completion
wait_mem0:
	lw x6, 0(x1)
	bne x6, x0, wait_mem0
wait_mem1:
	lw x6, 0(x2)
	bne x6, x0, wait_mem1

	# Set up Interrupts
    li     t1, 1
    slli   t2, t1, 3 # Interrupt Enable (MIE)
    csrs   mstatus, t2
    slli   t2, t1, 11 # Machine External Interrupt Enable (MEIE)
    csrs   mie, t2


	# Set up Floating-Point
    li     t1, 1
    slli   t1, t1, 13 # FP
    csrs   mstatus, t1

    # Set up stack pointer
	la sp, _stack_end

    /* Set up mtvec to point to the start of the vector table */
	la t0, .vectors
	or t0, t0, 1
	csrw mtvec, t0

    /* Begin data initialization */
	la t0, _text_end
	la t1, _data_start
	la t2, _data_end
    
    /* Check if data section is empty, if so, skip copy loop */
	bge t1, t2, copy_loop_end

    /* Begin data copy loop */
copy_loop:
    /* Copy data from _text_end to _data_start */
	lw a0, 0(t0)
	sw a0, 0(t1)
    
    /* Increment both source and destination pointers */
	add t0, t0, 4
	add t1, t1, 4
    
    /* Check if end of data section is reached, if not, continue copy */
	ble t1, t2, copy_loop

copy_loop_end:

    /* Begin BSS section clear */
	la t1, _bss_start
	la t2, _bss_end
    
    /* Check if BSS section is empty, if so, skip clear loop */
	bge t1, t2, zero_loop_end

    /* Begin BSS clear loop */
zero_loop:
    /* Write 0 to each word in BSS section */
	sw zero, 0(t1)
    
    /* Increment BSS pointer */
	add t1, t1, 4
    
    /* Check if end of BSS section is reached, if not, continue clear */
	ble t1, t2, zero_loop

zero_loop_end:

    /* Set both argc and argv to 0 */
	mv a0, zero
	mv a1, zero
    
    /* Call main function */
	jal main
    
    /* If main returns, jump to trap */
	j trap

/* -------------------------------------------------------------------------- */
/* DEFAULT EXCEPTION HANDLER */

.section .text.default_handler
.weak default_handler

default_handler:
trap:
    /* Infinite loop */
	j trap

/* -------------------------------------------------------------------------- */
/* EXCEPTION VECTORS */

.section .vectors, "ax"
.option norvc

	.org 0x00
	j reset_handler
	.rept 10
	    j default_handler
	.endr
	j default_handler /* external_irq_handler */
	.rept 4
	    j default_handler
	.endr
	j irq_0_handler
	j irq_1_handler
	j irq_2_handler
	j irq_3_handler
	j irq_4_handler
	j irq_5_handler
	j irq_6_handler
	j irq_7_handler
	j irq_8_handler
	j irq_9_handler
	j irq_10_handler
	j irq_11_handler
	j irq_12_handler
	j irq_13_handler
	j irq_14_handler
	j irq_nmi_handler

    /* IBEX - Reset vector */
	.org 0x80
	j reset_handler

    /* IBEX - Illegal instruction exception handler */
	.org 0x84
	j default_handler

    /* IBEX - Ecall handler */
	.org 0x88
	j default_handler

/* -------------------------------------------------------------------------- */
/* WEAK ALIASES */

.weak irq_0_handler
.weak irq_1_handler
.weak irq_2_handler
.weak irq_3_handler
.weak irq_4_handler
.weak irq_5_handler
.weak irq_6_handler
.weak irq_7_handler
.weak irq_8_handler
.weak irq_9_handler
.weak irq_10_handler
.weak irq_11_handler
.weak irq_12_handler
.weak irq_13_handler
.weak irq_14_handler
.weak irq_nmi_handler

.set irq_0_handler, default_handler
.set irq_1_handler, default_handler
.set irq_2_handler, default_handler
.set irq_3_handler, default_handler
.set irq_4_handler, default_handler
.set irq_5_handler, default_handler
.set irq_6_handler, default_handler
.set irq_7_handler, default_handler
.set irq_8_handler, default_handler
.set irq_9_handler, default_handler
.set irq_10_handler, default_handler
.set irq_11_handler, default_handler
.set irq_12_handler, default_handler
.set irq_13_handler, default_handler
.set irq_14_handler, default_handler
.set irq_nmi_handler, default_handler