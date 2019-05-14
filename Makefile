obj = main.o entry64.o cache64.o pagetable64.o exceptions.o trap.o
cur_dir = $(PWD)
asmarg = -I $(cur_dir)/include -c -D__ASSEMBLY__

armos: $(obj) link64.lds
	gcc $(obj) -T link64.lds -o armos

%.o: %.S
	gcc $(asmarg) $^ -o $@

%.c: %.c
	gcc $(carg) $^ -o $@

link64.lds: link64.lds.S
	gcc -E -P -x assembler-with-cpp -I $(cur_dir)/include -no-pie -nostdinc -nostdlib -D__ASSEMBLY__ link64.lds.S -o link64.lds

main.o: main.c
	gcc $(asmarg) $< -o $@

clean:
	rm *.o armos
