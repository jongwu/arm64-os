#include "fdt.h"
#include "chdev.h"

void *_libkvmplat_dtb;

void init_dtb(void *pdtb)
{
	_libkvmplat_dtb = pdtb;
}

void _libkvmplat_start(void *dtb_pointer)
{
//	init_dtb(dtb_pointer);
	_libkvmplat_dtb = dtb_pointer;
	kvmplat_init_console();
	main();
}

int main()
{
	printd("*************************\n");
	printd("*  HELLO, I am armos    *\n");
	printd("*************************\n");
	while(1);
	return 0;
}
