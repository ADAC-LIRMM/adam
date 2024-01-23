/* Authors: Soriano Theo; Felipe Alencar */

OUTPUT_ARCH(riscv)

/* Required to correctly link newlib nano */
GROUP(-lnosys -lc_nano -lgcc -lsupc++)

_stack_size = 8192;
_heap_size  = 8192;

/* Memory */
MEMORY
{
	ROM (rx)  : ORIGIN = 0x01000000, LENGTH = 524288
    RAM (w)   : ORIGIN = 0x02000000, LENGTH = 524288
}

/* Sections */
SECTIONS
{
	.text :
	{
		. = ALIGN(4);
		_text_start = .;
		
		KEEP(*(.vectors))
		*(.text)
		*(.text.*)

		KEEP(*(.init))
		KEEP(*(.fini))

		/* .ctors */
		*crtbegin.o(.ctors)
		*crtbegin?.o(.ctors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
		*(SORT(.ctors.*))
		*(.ctors)

		/* .dtors */
		*crtbegin.o(.dtors)
		*crtbegin?.o(.dtors)
		*(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
		*(SORT(.dtors.*))
		*(.dtors)

        *(.lit)
        *(.shdata)

		*(.rodata)
		*(.rodata.*)
		KEEP(*(.eh_frame*))

		*(.shbss)

		*(.srodata.*)

		. = ALIGN(4);
		_text_end = .;
	} > ROM

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
	} > RAM AT> ROM

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
	} > RAM

	.heap (NOLOAD) :
	{
		. = ALIGN(4);
		_heap_start = .;
		
		. = . + _heap_size;
		
		. = ALIGN(4);
		_heap_end = .;
	} > RAM

	.stack (NOLOAD) :
	{
		. = ALIGN(4);
		_stack_start = .;

		. = . + _stack_size;
		
		. = ALIGN(4);
		_stack_end = .;
	} > RAM
}
