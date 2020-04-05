void trap_el1_irq(void)
{
	printd("catch irq\n");
	gic_handle_irq();
}

void trap_el1_sync()
{
	printd("catch sync trap\n");
        return;
}

void invalid_trap_handler()
{
	printd("catch invalid trap\n");
        return;
}

