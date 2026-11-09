#include <stdint.h>
#include <stdio.h>
#include "gem5/m5ops.h"

extern uint64_t hot_line;

extern void preload_hot(uint64_t *hot);
extern void evict_hot();
extern void window_body(uint64_t *hot);

// extern void test_function();

int
main(void)
{
    uint64_t tmp = 0;

    m5_reset_stats(0, 0);
    uint64_t start_time = m5_rpns();
    __asm__ volatile ("addi %0, %0, 1" : "+r"(tmp));

    uint64_t end_time = m5_rpns();
    printf("Test function took %lu ticks.\n", end_time - start_time);

    volatile uint64_t sink = 0;

    preload_hot(&hot_line);
    window_body(&hot_line);
    // 
    m5_reset_stats(0, 0);
    uint64_t start_time1 = m5_rpns();
    window_body(&hot_line);

    uint64_t end_time1 = m5_rpns();
    uint64_t ns1 = end_time1 - start_time1;

    evict_hot();
    // 
    m5_reset_stats(0, 0);
    uint64_t start_time2 = m5_rpns();
    window_body(&hot_line);
    // m5_dump_stats(0, 0);

    uint64_t end_time2 = m5_rpns();
    uint64_t ns2 = end_time2 - start_time2;

    printf("ns1 = %lu and ns2 = %lu\n", ns1, ns2);

    sink ^= hot_line;
    sink ^= tmp;
    return (int)(sink & 0xff);
}
