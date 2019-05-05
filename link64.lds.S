/* SPDX-License-Identifier: BSD-3-Clause */
/*
 * Authors: Wei Chen <wei.chen@arm.com>
 *
 * Copyright (c) 2018, Arm Ltd. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its
 *    contributors may be used to endorse or promote products derived from
 *    this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *
 * THIS HEADER MAY NOT BE EXTRACTED OR MODIFIED IN ANY WAY.
 */
/* #include <uk/arch/limits.h> */

/* QEMU-AArch64 virt platform's ram base address */
/* #define RAM_BASE_ADDR 0x40000000 */

/* Reserve first 1MB for DTB */
/* #define DTB_RESERVED_SIZE 0x100000 */

OUTPUT_FORMAT("elf64-littleaarch64")
OUTPUT_ARCH(aarch64)
ENTRY(_libkvmplat_entry)

/*
 * We use mmu to control each section's attribute, so the boundaries
 * of sections with different memory attributes must be 4KiB alignment.
 * For instance, the dtb section is readonly, but the text section
 * is readonly+exec. So the _text must start at a 4KiB alignment
 * address.
 */
SECTIONS {
	. = 0x40000000;

	/* Place DTB binary at the beginning of the RAM */
	_dtb = .;
	. = . + 0x100000;

	/* Code */
	_text = .;
	.text :
	{
		*(.text)
		*(.text.*)
	}

	_etext = .;

	__eh_frame_hdr_end = .;

	/* Read-only data */
	_rodata = .;
	.rodata :
	{
		*(.rodata)
		*(.rodata.*)
	}


	_erodata = .;

	uk_ctortab = .;
	.uk_ctortab :
	{
		*(SORT_BY_NAME(.uk_ctortab[0-7]))
		LONG(0)
	}

	/* Read-write data that is initialized explicitly in code */
	_data = .;
	.data :
	{
		*(.data)
		*(.data.*)
	}

	__bss_start = .;
	/* Read-write data that is not initialized explicitly in code */
	.bss :
	{
		*(.bss)
		*(.bss.*)
		*(COMMON)
		. = 0x1000;
	/*
	 * TODO
	 * We can define the stack and page-table here, and free them once
	 * the boot is done.
	 */
	}

	_end = .;
}
