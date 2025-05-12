/* Authors: Soriano Theo; Felipe Alencar */

OUTPUT_ARCH(riscv)

/* Required to correctly link newlib nano */
GROUP(-lnosys -lc_nano -lgcc -lsupc++)

_stack_size = 1024;
_heap_size  = 1024;

/* Memory */
MEMORY
{
	ROM (rx)  : ORIGIN = 0x01000000, LENGTH = 8192  /* Bootloader code in ROM */
    RAM (w)   : ORIGIN = 0x02000000, LENGTH = 81920  /* RAM for data, heap, stack, and application */
}

/* Stack pointer size */
_stack_ptr_size = 4; /* Size of stack pointer, 4 for 32-bit, 8 for 64-bit */

/* Entry point of the application (to be loaded by the bootloader) */
APP_LOAD_ADDR = 0x02008000; /* Starting address in RAM for application */
APP_ENTRY_POINT = 0x02008000; /* Entry point of the application */

/* Sections */
SECTIONS
{
	/* .text section: Bootloader code */
	.text :
	{
		. = ALIGN(4);
		_text_start = .;
		
		KEEP(*(.vectors))  /* Vector table for bootloader */
		*(.text)           /* Bootloader text section */
		*(.text.*)         /* Other text sections */

		KEEP(*(.init))     /* Bootloader init code */
		KEEP(*(.fini))     /* Bootloader cleanup code */

		/* Constructors and destructors */
		*crtbegin.o(.ctors)
		*crtbegin?.o(.ctors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
		*(SORT(.ctors.*))
		*(.ctors)

		*crtbegin.o(.dtors)
		*crtbegin?.o(.dtors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
		*(SORT(.dtors.*))
		*(.dtors)

        *(.lit)
        *(.shdata)
		*(.rodata)        /* Read-only data */
		*(.rodata.*)
		KEEP(*(.eh_frame*))

		*(.shbss)
		*(.srodata.*)

		. = ALIGN(4);
		_text_end = .;
	} > ROM  /* Bootloader code goes into ROM */

	/* Stack pointer initialization section (stack pointer management for bootloader) */
	.stack_ptr (NOLOAD) :
    {
        . = ALIGN(4);
        _stack_ptr_start = .;
        
        . = . + _stack_ptr_size;  /* Set stack pointer size */
        
        . = ALIGN(4);
        _stack_ptr_end = .;
    } > RAM  /* Stack pointer goes into RAM, where the stack will be placed */

	/* .data section: Initialized data loaded into RAM */
	.data :
	{
		. = ALIGN(4);
		_data_start = .;
		
		*(vtable)
		*(.data)
		*(.data.*)
		*(.sdata)
		*(.sdata.*)

		. = ALIGN(4);
		PROVIDE_HIDDEN (__preinit_array_start = .);
		KEEP(*(.preinit_array))
		PROVIDE_HIDDEN (__preinit_array_end = .);

		. = ALIGN(4);
		PROVIDE_HIDDEN (__init_array_start = .);
		KEEP(*(SORT(.init_array.*)))
		KEEP(*(.init_array))
		PROVIDE_HIDDEN (__init_array_end = .);

		. = ALIGN(4);
		PROVIDE_HIDDEN (__fini_array_start = .);
		KEEP(*(SORT(.fini_array.*)))
		KEEP(*(.fini_array))
		PROVIDE_HIDDEN (__fini_array_end = .);

		KEEP(*(.jcr*))
		
		. = ALIGN(4);
		_data_end = .;
	} > RAM AT> ROM  /* .data is loaded from ROM to RAM */

	/* Ensure proper memory initialization for .data section */
	_data_load = LOADADDR(.data);

	/* .bss section: Uninitialized data (loaded into RAM) */
	.bss (NOLOAD) :
	{
		. = ALIGN(4);
		_bss_start = .;
		
		*(.bss)
		*(.bss.*)
		*(.sbss)
		*(.sbss.*)
		*(COMMON)
		
		. = ALIGN(4);
		_bss_end = .;
	} > RAM  /* .bss section goes into RAM */

	_end = .;
	PROVIDE (end = .);

	/* .heap section: Heap memory for dynamic allocation */
	.heap (NOLOAD) :
	{
		. = ALIGN(4);
		_heap_start = .;
		
		. = . + _heap_size;
		
		. = ALIGN(4);
		_heap_end = .;
	} > RAM  /* Heap goes into RAM */

	/* .stack section: Stack memory for bootloader and initial setup */
	.stack (NOLOAD) :
	{
		. = ALIGN(4);
		_stack_start = .;

		. = . + _stack_size;
		
		. = ALIGN(4);
		_stack_end = .;
	} > RAM  /* Stack goes into RAM */

	/* Application load section: Reserved memory for the application */
	.application (NOLOAD) :
	{
		. = ALIGN(4);
		_app_start = .;
		
		/* Reserve space in RAM for the application to be loaded by the bootloader */
		. = . + (81920 - 0x1000);  /* Adjust based on the app's size */

		.app_end = .;
	} > RAM  /* Application memory region in RAM */
}
