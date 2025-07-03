MEM0_LENGTH  = DEFINED(MEM0_LENGTH)  ? MEM0_LENGTH  : 524288;
MEM1_LENGTH  = DEFINED(MEM1_LENGTH)  ? MEM1_LENGTH  : 524288;
LPMEM_LENGTH = DEFINED(LPMEM_LENGTH) ? LPMEM_LENGTH : 4096;

MEMORY
{
    LPMEM (rwx) : ORIGIN = 0x00000000, LENGTH = LPMEM_LENGTH
    MEM0  (rx)  : ORIGIN = 0x01000000, LENGTH = MEM0_LENGTH
    MEM1  (rw)  : ORIGIN = 0x02000000, LENGTH = MEM1_LENGTH
}

STACK_SIZE = DEFINED(STACK_SIZE) ? STACK_SIZE : 0x2000;

ENTRY(_start)

SECTIONS
{
    .mem0 :
    {
        . = ALIGN(64);
        _stext = .;

        KEEP(*(.vectors))
        *(.text)
        *(.text.*)
        *(.gnu.linkonce.t.*)
        KEEP(*(.context))

        KEEP(*(.init))
        KEEP(*(.fini))

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
        *(.rodata)
        *(.rodata.*)
        *(.srodata)
        *(.srodata.*)
        KEEP(*(.eh_frame*))

        *(.gcc_except_table.*)

        . = ALIGN(64);
        _etext = .;
    } > MEM0

    .mem1_at_mem0 :
    {
        . = ALIGN(64);
        _sdata = .;

        *(vtable)
        *(.data)
        *(.data.*)
        *(.gnu.linkonce.d.*)
        *(.sdata)
        *(.sdata.*)
        *(.sdata2)
        *(.sdata2.*)

        *(.rodata.fp)
        *(.rodata.fp.*)

        . = ALIGN(64);
        PROVIDE(__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE(__preinit_array_end   = .);

        . = ALIGN(64);
        PROVIDE(__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE(__init_array_end   = .);

        . = ALIGN(64);
        PROVIDE(__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE(__fini_array_end   = .);

        KEEP(*(.jcr*))

        . = ALIGN(64);
        _global_pointer = . + 0x800;

        . = ALIGN(64);
        _edata = .;
    } > MEM1 AT> MEM0

    .mem1_noload (NOLOAD) :
    {
        . = ALIGN(64);
        _sbss = .;

        *(.bss*)
        *(COMMON)

        . = ALIGN(64);
        _ebss = .;
        _sheap = .;

        . = ORIGIN(MEM1) + LENGTH(MEM1) - STACK_SIZE - 255;
        . = ALIGN(64);
        _eheap = .;
        _sstack = .;

        . = . + STACK_SIZE;
        . = ALIGN(64);
        _estack = .;
    } > MEM1

    .lpmem_at_mem0 :
    {
        . = ALIGN(64);
        _slpmem = .;

        KEEP(*(.lpmem.vectors))
        KEEP(*(.lpmem))
        KEEP(*(.lpmem.*))

        . = . + 1024; /* Min. Stack Size */

        . = ORIGIN(LPMEM) + LENGTH(LPMEM) - 63;
        . = ALIGN(64);
        _elpmem = .;
    } > LPMEM AT> MEM0

    _end = .;
}
