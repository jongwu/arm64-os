arch=$(uname -m)
ifeq ($arch,"aarch64") 
cc=gcc
else
cc=aarch64-linux-gnu-gcc
endif

c-device = device/pl011.c
obj-dev = device/pl011.o
c-fdt = fdt/fdt.c fdt/fdt_interrupts.c fdt/fdt_ro.c fdt/fdt_strerror.c fdt/fdt_wip.c fdt/fdt_addresses.c fdt/fdt_empty_tree.c fdt/fdt_overlay.c fdt/fdt_rw.c fdt/fdt_sw.c
obj-fdt = fdt/fdt.o fdt/fdt_ro.o fdt/fdt_strerror.o fdt/fdt_wip.o fdt/fdt_addresses.o fdt/fdt_empty_tree.o fdt/fdt_overlay.o fdt/fdt_rw.o fdt/fdt_sw.o
obj = main.o entry64.o cache64.o pagetable64.o exceptions.o trap.o $(obj-dev) $(obj-fdt) $(obj-other)
obj-other = nolib/string.o nolib/errno.o
#obj-nolib = nolib/asprintf.o nolib/ctype.o nolib/getopt.o nolib/malloc.o nolib/stdio.o nolib/asprintf.o nolib/errno.o nolib/stdlib.o nolib/sscanf.o nolib/string.o
cur_dir = $(PWD)
asmarg = -I $(cur_dir)/include -c -D__ASSEMBLY__ -g
carg = -I$(cur_dir)/include -I$(cur_dir)/nolib/include -I$(cur_dir)/fdt/include -nostdinc -nostdlib -fno-stack-protector  -fno-omit-frame-pointer -Wall -Wextra -c -g
ldflag = -nostdinc -nostdlib -Wl,--omagic -Wl,--build-id=none
armos: $(obj) link64.lds
	$(cc) $(obj) $(ldflag) -T link64.lds -static -o armos

%.o: %.S
	$(cc) $(asmarg) $^ -o $@

%.o: %.c
	$(cc) $(carg) $^ -o $@

devcie/%.o: device/%.c
	$(cc) $(carg) $^ -o $@

fdt/%.o: fdt/%.c
	$(cc) $(carg) $^ -o $@

nolib/string.o: nolib/string.c
	$(cc) $(carg) $^ -o $@

nolib/stdlib.o: nolib/stdlib.c
	$(cc) $(carg) $^ -o $@

nolib/errno.: nolib/errno.c
	$(cc) $(carg) $^ -o $@

nolib/stdio.o: nolib/stdio.c
	$(cc) $(carg) $^ -o $@
#nolib/%.o: nolib/%.c
#	$(cc) $(carg) $^ -o $@

link64.lds: link64.lds.S
	$(cc) -E -P -x assembler-with-cpp -I $(cur_dir)/include -no-pie -nostdinc -nostdlib -D__ASSEMBLY__ link64.lds.S -o link64.lds
#	$(cc) -E -P -x assembler-with-cpp -I $(cur_dir)/include -no-pie -nostdinc -nostdlib -D__ASSEMBLY__ link64.lds.S -o link64.lds

main.o: main.c
	$(cc) $(carg) $< -o $@

clean:
	rm *.o armos
