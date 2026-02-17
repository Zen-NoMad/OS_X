OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)
ENTRY(_start_32)

SECTIONS{
    . = 2M;

    .multiboot ALIGN(4) :
    {
        KEEP(*(.multiboot))
        KEEP(*(.multiboot2))
    }

    .text ALIGN(4K) :
    {
        *(.text)
        *(.text.*)
    }

    .rodata ALIGN(4K) :
    {
        *(.rodata)
        *(.rodata.*)
    }

    .data ALIGN(4K) :
    {
        _sdata = .;
        *(.data)
        *(.data.*)
        _edata = .;
    }

    .bss ALIGN(4K) :
    {
        _sbss = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _ebss = .;
    }

    stack_top = .;
}