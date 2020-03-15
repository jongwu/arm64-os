#include "fdt.h"
#include "libfdt.h"
#include "io.h"

#define LCR_H_WLEN8          (0x3 << 5)
#define CR_TXE                       (1 << 8)
#define CR_UARTEN            (1 << 0)
#define REG_UARTDR_OFFSET 0x0
#define REG_UARTFR_OFFSET    0x18
#define REG_UARTLCR_H_OFFSET 0x2C
#define REG_UARTCR_OFFSET 0x30
#define REG_UARTIMSC_OFFSET 0x38
#define REG_UARTICR_OFFSET 0x34
/* Raw interrupt status register */
#define REG_UARTRIS_OFFSET      0x3C
/* Masked interrupt status register */
#define REG_UARTMIS_OFFSET      0x40
/* Interrupt clear register */
#define REG_UARTICR_OFFSET      0x44
#define FR_TXFF                      (1 << 5)    /* Transmit FIFO/reg full */

void *pl011_uart_bas;
extern void *_libkvmplat_dtb;
int pl011_uart_initialized = 0;

#define PL011_REG(r) ((uint16_t *)(pl011_uart_bas + (r)))
#define PL011_REG_READ(r) ioreg_read16(PL011_REG(r))
#define PL011_REG_WRITE(r, data) ioreg_write16(PL011_REG(r), data)

static void init_pl011(void *offset)
{
	pl011_uart_bas = offset;

        /* Mask all interrupts */
        PL011_REG_WRITE(REG_UARTIMSC_OFFSET, \
                PL011_REG_READ(REG_UARTIMSC_OFFSET) & 0xf800);

        /* Clear all interrupts */
        PL011_REG_WRITE(REG_UARTICR_OFFSET, 0x07ff);

        /* Disable UART for configuration */
        PL011_REG_WRITE(REG_UARTCR_OFFSET, 0);

        /* Select 8-bits data transmit and receive */
        PL011_REG_WRITE(REG_UARTLCR_H_OFFSET, \
                (PL011_REG_READ(REG_UARTLCR_H_OFFSET) & 0xff00) | LCR_H_WLEN8);

        /* Just enable UART and data transmit/receive */
        PL011_REG_WRITE(REG_UARTCR_OFFSET, CR_TXE | CR_UARTEN);
	pl011_uart_initialized = 1;
}

void kvmplat_init_console(void)
{
        int offset, len, naddr, nsize, check;
        const uint64_t *regs;
        uint64_t reg_uart_bas;

	check = fdt_check_header(_libkvmplat_dtb);
	if (check < 0)
		return;
        offset = fdt_node_offset_by_compatible(_libkvmplat_dtb, \
                                        -1, "arm,pl011");
        if (offset < 0)
	{
                printd("No console UART found!\n");
		return;
	}

        naddr = fdt_address_cells(_libkvmplat_dtb, offset);
        if (naddr < 0 || naddr >= FDT_MAX_NCELLS)
	{
                printd("Could not find proper address cells!\n");
		return;
	}

        nsize = fdt_size_cells(_libkvmplat_dtb, offset);
        if (nsize < 0 || nsize >= FDT_MAX_NCELLS)
	{
                printd("Could not find proper size cells!\n");
		return;
	}

        regs = fdt_getprop(_libkvmplat_dtb, offset, "reg", &len);
        if (regs == NULL || (len < (int)sizeof(fdt32_t) * (naddr + nsize)))
	{
                printd("Bad 'reg' property");
	}

        reg_uart_bas = fdt64_to_cpu(regs[0]);

        init_pl011(reg_uart_bas);
        printd("PL011 UART initialized\n");
}

static void pl011_write(char a)
{
        /*
         * Avoid using the UART before base address initialized,
         * or CONFIG_KVM_EARLY_DEBUG_PL011_UART doesn't be enabled.
         */
        if (!pl011_uart_initialized)
                return;

        /* Wait until TX FIFO becomes empty */
        while (PL011_REG_READ(REG_UARTFR_OFFSET) & FR_TXFF);

        PL011_REG_WRITE(REG_UARTDR_OFFSET, a & 0xff);
}

static void pl011_putc(char a)
{
        if (a == '\n')
                pl011_write('\r');
        pl011_write(a);
}

void printd(char *fmt)
{
	while(*fmt)
	{
		pl011_putc(*fmt++);
	}
}
