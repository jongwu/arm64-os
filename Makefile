obj = main.o entry64.o cache64.o pagetable64.o
cur_dir = $(PWD)
carg = -I $(cur_dir) -c

armos: $(obj)
	gcc $(obj) -T link64.lds.S -o armos

%.o: %.S
	gcc $(carg) $^ -o $@

main.o: main.c
	gcc $(carg) $< -o $@

clean:
	rm *.o armos
