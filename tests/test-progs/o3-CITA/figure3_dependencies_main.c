#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>

extern void figure3_dependencies(uint64_t seed, uint64_t results[5]);

int
main(void)
{
    uint64_t results[5];

    figure3_dependencies(1, results);

    printf("i0=%" PRIu64 " i1=%" PRIu64 " i2=%" PRIu64
           " i3=%" PRIu64 " i4=%" PRIu64 "\n",
           results[0], results[1], results[2], results[3], results[4]);

    return 0;
}
