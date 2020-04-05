#include<typesc.h>
#include<nolib/stdint.h>

#define __IOREG_WRITE(bits) \
static inline void \
        ioreg_write##bits(volatile uint##bits##_t *addr, \
                                                uint##bits##_t value) \
                { *addr = value; }

#define __IOREG_READ(bits) \
static inline uint##bits##_t \
        ioreg_read##bits(const volatile uint##bits##_t *addr) \
                { return *addr; }
__IOREG_READ(8)
__IOREG_READ(16)
__IOREG_READ(32)
__IOREG_READ(64)

__IOREG_WRITE(8)
__IOREG_WRITE(16)
__IOREG_WRITE(32)
__IOREG_WRITE(64)

/*static inline uint16_t ioreg_read16(uint16_t *addr)
{
	return *addr;
}

static inline uint16_t ioreg_write16(uint16_t *addr, uint16_t data)
{
	*addr = data;
	return 0;
}
*/
