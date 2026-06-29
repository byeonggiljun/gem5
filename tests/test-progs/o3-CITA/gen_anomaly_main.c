#include <stdint.h>

extern uint64_t hot_line;
extern unsigned char evict_buf[];

extern void preload_hot(uint64_t *hot);
extern void evict_hot(uint64_t *hot, unsigned char *evict);
extern void window_body(uint64_t *hot, unsigned char *evict, long iterations);

int
main(void)
{
    volatile uint64_t sink = 0;

    preload_hot(&hot_line);
    window_body(&hot_line, evict_buf, 1000);

    evict_hot(&hot_line, evict_buf);
    window_body(&hot_line, evict_buf, 1000);

    sink ^= hot_line;
    return (int)(sink & 0xff);
}
