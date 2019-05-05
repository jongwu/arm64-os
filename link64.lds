OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(_libkvmplat_entry)
SECTIONS {
 . = 0x40000000;
 _dtb = .;
 . = . + 0x100000;
 _text = .;
 .text :
 {
  *(.text)
  *(.text.*)
 }
 . = ALIGN((1 << 12));
 _etext = .;
 __eh_frame_start = .;
 .eh_frame :
 {
  *(.eh_frame)
  *(.eh_frame.*)
 }
 __eh_frame_end = .;
 __eh_frame_hdr_start = .;
 .eh_frame_hdr :
 {
  *(.eh_frame_hdr)
  *(.eh_frame_hdr.*)
 }
 . = ALIGN((1 << 12));
 __eh_frame_hdr_end = .;
 _rodata = .;
 .rodata :
 {
  *(.rodata)
  *(.rodata.*)
 }
 _erodata = .;
 . = ALIGN((1 << 12));
 uk_ctortab = .;
 .uk_ctortab :
 {
  *(SORT_BY_NAME(.uk_ctortab[0-7]))
  LONG(0)
 }
 _ctors = .;
 .preinit_array : {
  . = ALIGN(0x8);
  PROVIDE_HIDDEN (__preinit_array_start = .);
  KEEP (*(.preinit_array))
  PROVIDE_HIDDEN (__preinit_array_end = .);
 }
 .init_array : {
  . = ALIGN(0x8);
  PROVIDE_HIDDEN (__init_array_start = .);
  KEEP (*(SORT_BY_INIT_PRIORITY(.init_array.*) SORT_BY_INIT_PRIORITY(.ctors.*)))
  KEEP (*(.init_array .ctors))
  PROVIDE_HIDDEN (__init_array_end = .);
 }
 _ectors = .;
 . = ALIGN((1 << 12));
 _data = .;
 .data :
 {
  *(.data)
  *(.data.*)
 }
 _edata = .;
 . = ALIGN((1 << 12));
 __bss_start = .;
 .bss :
 {
  *(.bss)
  *(.bss.*)
  *(COMMON)
  . = ALIGN((1 << 12));
 }
 _end = .;
}
