static inline uint16_t ioreg_read16(uint16_t *addr)
{
	return *addr;
}

static inline uint16_t ioreg_write16(uint16_t *addr, uint16_t data)
{
	*addr = data;
}
