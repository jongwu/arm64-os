#include "fdt.h"
#include "chdev.h"

void *_libkvmplat_dtb;

void init_dtb(void *pdtb)
{
	_libkvmplat_dtb = pdtb;
}

void _libkvmplat_start(void *dtb_pointer)
{
	init_dtb(dtb_pointer);
	_libkvmplat_init_console();
	main();
}

int main()
{
	printd("armos boot up\n");
	return 0;
}
