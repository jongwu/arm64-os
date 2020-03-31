#include <limits.h>
#include <asm.h>
#include <mm.h>
#include <cpu_defs.h>
//#include <sections.h>
#include <entry.h>

.global page_table_size
.data
.align 3
page_table_size:
	.dword 0x0

/*
 * The registers used by _libkvmplat_start:
 * x0 - FDT pointer
 */

.text
ENTRY(_libkvmplat_entry)
	/* Calculate the image size, x15 contains the size of dtb*/
	ldr x25, =_dtb
	ldr x26, =_end
	mov x15, x25
	sub x15, x26, x15

	/* Round up the size to 2MB */
	mov x17, #(IMAGE_ROUNDUP_SIZE - 1)
	add x15, x15, x17
	lsr x15, x15, #IMAGE_ROUNDUP_SHIFT
	lsl x15, x15, #IMAGE_ROUNDUP_SHIFT

	/*
	 * How many bytes would be used for L3_TABLE
	 * ((x15 >> 12 << 3)
	 */
	lsr x17, x15, #9

	/* Total bytes for pagetable */
	add x17, x17, #L0_TABLE_SIZE
	add x17, x17, #L1_TABLE_SIZE
	add x17, x17, #L2_TABLE_SIZE

	/*
	 * We will disable MMU and CACHE before pagetable is ready. This
	 * means we will change memory with cache disabled, so we need to
	 * invalidate the cache to ensure there is no stall data in it.
	 * But we don't know the size of the RAM either. And it would be
	 * expensive to invalidate the whole cache. In this case, just
	 * just need to invalidate what we are going to use:
	 * DTB, TEXT, DATA, BSS, pagetables and bootstack.
	 */
	add x27, x26, x17
	add x27, x27, #__STACK_SIZE
	sub x1, x27, x25
	bl clean_and_invalidate_dcache_range

	/* Disable the MMU and D-Cache. */
	dsb sy
	mrs x2, sctlr_el1
	mov x3, #SCTLR_M|SCTLR_C
	bic x2, x2, x3
	msr sctlr_el1, x2
	isb

	/*
	 * Clean the boot stack and page table. As _end, PAGE_TABLE_SIZE and
	 * BOOT_STACK_SIZE are page_size alignment, the boot stack can be
	 * 64-bytes alignment too. Execute 4 stp consecutively without boundary
	 * check would be safe here.
	 */
1:
	stp xzr, xzr, [x26], #16
	stp xzr, xzr, [x26], #16
	stp xzr, xzr, [x26], #16
	stp xzr, xzr, [x26], #16
	cmp x26, x27
	b.lo 1b

	mov sp, x27

	/* Set the context id */
	msr contextidr_el1, xzr

	/* Save page table size for later usage */
	ldr x25, =page_table_size
	str x17, [x25]

	/* Create a pagetable to do PA == VA mapping */
	bl create_pagetables

	/* Setup exception vector table address before enable MMU */
	ldr x29, =vector_table
	msr VBAR_EL1, x29

	/* Enable the mmu */
	bl start_mmu

	/* Load dtb address to x0 as a parameter */
	bl test
	ldr x0, =_dtb
	b _libkvmplat_start
END(_libkvmplat_entry)

ENTRY(_libkvmplat_newstack)
	/* Setup new stack */
	mov sp, x0

	/* Setup parameter for _libkvmplat_entry2 */
	mov x0, x2

	/* Branch to _libkvmplat_entry2 */
	br x1
END(_libkvmplat_newstack)

test:
	nop
	ret x30
