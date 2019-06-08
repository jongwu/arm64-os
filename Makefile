c-device = device/pl011.c
obj-dev = device/pl011.o
c-fdt = fdt/fdt.c fdt/fdt_interrupts.c fdt/fdt_ro.c fdt/fdt_strerror.c fdt/fdt_wip.c fdt/fdt_addresses.c fdt/fdt_empty_tree.c fdt/fdt_overlay.c fdt/fdt_rw.c fdt/fdt_sw.c
obj-fdt = fdt/fdt.o fdt/fdt_interrupts.o fdt/fdt_ro.o fdt/fdt_strerror.o fdt/fdt_wip.o fdt/fdt_addresses.o fdt/fdt_empty_tree.o fdt/fdt_overlay.o fdt/fdt_rw.o fdt/fdt_sw.o
obj = main.o entry64.o cache64.o pagetable64.o exceptions.o trap.o $(obj-dev) $(obj-fdt)
cur_dir = $(PWD)
asmarg = -I $(cur_dir)/include -c -D__ASSEMBLY__ -g
carg = -I$(cur_dir)/include -c -g
armos: $(obj) link64.lds
	gcc $(obj) -T link64.lds -o armos

%.o: %.S
	gcc $(asmarg) $^ -o $@

%.o: %.c
	gcc $(carg) $^ -o $@

devcie/%.o: device/%.c
	gcc $(carg) $^ -o $@

fdt/%.o: fdt/%.c
	gcc $(carg) $^ -o $@

link64.lds: link64.lds.S
	gcc -E -P -x assembler-with-cpp -I $(cur_dir)/include -no-pie -nostdinc -nostdlib -D__ASSEMBLY__ link64.lds.S -o link64.lds

main.o: main.c
	gcc $(carg) $< -o $@

clean:
	rm *.o armos
