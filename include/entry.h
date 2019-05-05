#define __ALIGN .align 2
#define ENTRY(name)     \
.globl name;            \
__ALIGN;                \
name:
#define IMAGE_ROUNDUP_SHIFT 21
#define END(name)       \
.size name, . - name

#define _AC(X,Y)    X
#define SCTLR_M         (_AC(1, UL) << 0)       /* MMU enable */
#define SCTLR_C         (_AC(1, UL) << 2)       /* Data/unified cache enable */
#define IMAGE_ROUNDUP_SIZE (0x1 << (IMAGE_ROUNDUP_SHIFT))
#define __PAGE_SHIFT            12
#define __PAGE_SIZE             (1 << __PAGE_SHIFT)
#define L0_TABLE_SIZE   __PAGE_SIZE
#define L1_TABLE_SIZE   (__PAGE_SIZE * 2)
#define L2_TABLE_SIZE   __PAGE_SIZE
#define __STACK_SIZE            (__PAGE_SIZE * (1 << __STACK_SIZE_PAGE_ORDER))
#define __STACK_SIZE_PAGE_ORDER 4
#define CTR_BYTES_PER_WORD  4
#define CTR_DMINLINE_WIDTH  4
#define CTR_DMINLINE_SHIFT  16
#define L3_SHIFT   12

/*
 * Definitions for Block and Page descriptor attributes
 */
/* Level 0 table, 512GiB per entry */
#define L0_SHIFT        39
#define L0_SIZE         (1ul << L0_SHIFT)
#define L0_OFFSET       (L0_SIZE - 1ul)
#define L0_INVAL        0x0 /* An invalid address */
        /* 0x1 Level 0 doesn't support block translation */
        /* 0x2 also marks an invalid address */
#define L0_TABLE        0x3 /* A next-level table */

/* Level 1 table, 1GiB per entry */
#define L1_SHIFT        30
#define L1_SIZE         (1 << L1_SHIFT)
#define L1_OFFSET       (L1_SIZE - 1)
#define L1_INVAL        L0_INVAL
#define L1_BLOCK        0x1
#define L1_TABLE        L0_TABLE

/* Level 2 table, 2MiB per entry */
#define L2_SHIFT        21
#define L2_SIZE         (1 << L2_SHIFT)
#define L2_OFFSET       (L2_SIZE - 1)
#define L2_INVAL        L1_INVAL
#define L2_BLOCK        L1_BLOCK
#define L2_TABLE        L1_TABLE

#define L2_BLOCK_MASK   _AC(0xffffffe00000, UL)

/* Level 3 table, 4KiB per entry */
#define L3_SHIFT        12
#define L3_SIZE         (1 << L3_SHIFT)
#define L3_OFFSET       (L3_SIZE - 1)
#define L3_SHIFT        12
#define L3_INVAL        0x0

/*
 * Each entry in L0_TABLE can link to a L1_TABLE which supports 512GiB
 * memory mapping. One 4K page can provide 512 entries. In this case,
 * one page for L0_TABLE is enough for current stage.
 */
#define L0_TABLE_OFFSET 0
#define L0_TABLE_SIZE   __PAGE_SIZE

/*
 * Each entry in L1_TABLE can map to a 1GiB memory or link to a
 * L2_TABLE which supports 1GiB memory mapping. One 4K page can provide
 * 512 entries. We need at least 2 pages to support 1TB memory space
 * for platforms like KVM QEMU virtual machine.
 */
#define L1_TABLE_OFFSET (L0_TABLE_OFFSET + L0_TABLE_SIZE)
#define L1_TABLE_SIZE   (__PAGE_SIZE * 2)

/*
 * Each entry in L2_TABLE can map to a 2MiB block memory or link to a
 * L3_TABLE which supports 2MiB memory mapping. We need a L3_TABLE to
 * cover image area for us to manager different sections attributes.
 * So, we need one page for L2_TABLE to provide 511 enties for 2MiB
 * block mapping and 1 entry for L3_TABLE link.
 */
#define L2_TABLE_OFFSET (L1_TABLE_OFFSET + L1_TABLE_SIZE)
#define L2_TABLE_SIZE   __PAGE_SIZE

/*
 * We will use Unikraft image's size to caculate the L3_TABLE_SIZE.
 * Because we allocate one page for L2 TABLE, fo the max image size
 * would be 1GB. It would be enough for current stage.
 */
#define L3_TABLE_OFFSET (L2_TABLE_OFFSET + L2_TABLE_SIZE)

#define L0_ENTRIES_SHIFT 9
#define L0_ENTRIES      (1 << L0_ENTRIES_SHIFT)
#define L0_ADDR_MASK    (L0_ENTRIES - 1)

#define Ln_ENTRIES_SHIFT 9
#define Ln_ENTRIES      (1 << Ln_ENTRIES_SHIFT)
#define Ln_ADDR_MASK    (Ln_ENTRIES - 1)
#define Ln_TABLE_MASK   ((1 << 12) - 1)
#define Ln_TABLE        0x3
#define Ln_BLOCK        0x1
#define TCR_T1SZ_SHIFT     16

#define L3_PAGE            0x3
