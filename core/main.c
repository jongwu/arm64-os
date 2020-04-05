#include "fdt.h"
#include "chdev.h"

void *_libkvmplat_dtb;

void init_dtb(void *pdtb)
{
	_libkvmplat_dtb = pdtb;
}

int main()
{
	printd("*************************\n");
	printd("*  HELLO, I am armos    *\n");
	printd("*************************\n");
	while(1);
	return 0;
}

void _libkvmplat_start(void *dtb_pointer)
{
	init_dtb(dtb_pointer);
	kvmplat_init_console();
	_dtb_init_gic(dtb_pointer);
	main();
}

