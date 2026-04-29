OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 4K
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 4K
}

SECTIONS
{
  .text : ALIGN(4)
  {
    KEEP(*(.init))
    KEEP(*(.text.startup))
    *(.text .text.*)
    *(.rodata .rodata.*)
    . = ALIGN(4);
  } > ROM

  .data : ALIGN(4)
  {
    __data_start = .;
    *(.sdata .sdata.*)
    *(.data .data.*)
    . = ALIGN(4);
    __data_end = .;
  } > RAM AT > ROM

  __data_load = LOADADDR(.data);

  .bss (NOLOAD) : ALIGN(4)
  {
    __bss_start = .;
    *(.sbss .sbss.*)
    *(.bss .bss.*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end = .;
  } > RAM

  /* Keep the initial SP inside RAM; 0x00001000 is used by LED MMIO in Top2. */
  __stack_top = ORIGIN(RAM) + LENGTH(RAM) - 4;

  /DISCARD/ :
  {
    *(.comment*)
    *(.note*)
    *(.eh_frame*)
    *(.gnu.attributes*)
    *(.riscv.attributes*)
    *(.interp)
    *(.dynamic)
    *(.dynsym)
    *(.dynstr)
    *(.gnu.hash)
    *(.hash)
    *(.got*)
    *(.plt*)
  }
}
