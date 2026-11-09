#include <stdint.h>
#include <stdio.h>
extern void benchmark_icache(uint64_t *ns1, uint64_t *ns2);

int
main(void)
{
    uint64_t ns1 = 0;
    uint64_t ns2 = 0;

    benchmark_icache(&ns1, &ns2);

    printf("ns1 = %ld and ns2 = %ld\n", ns1, ns2);

    return 0;
}
