#include <stdint.h>
#include <stdio.h>

extern void warm_target(void);
extern uint64_t measure_target_once(void);
extern void evict_icache(void);

int
main(void)
{
    const int samples = 32;
    uint64_t hot_sum = 0;
    uint64_t cold_sum = 0;
    uint64_t hot_min = UINT64_MAX;
    uint64_t cold_min = UINT64_MAX;

    for (int i = 0; i < samples; ++i) {
        uint64_t hot_cycles;
        uint64_t cold_cycles;

        warm_target();
        hot_cycles = measure_target_once();

        evict_icache();
        cold_cycles = measure_target_once();

        if (hot_cycles < hot_min)
            hot_min = hot_cycles;
        if (cold_cycles < cold_min)
            cold_min = cold_cycles;

        hot_sum += hot_cycles;
        cold_sum += cold_cycles;

        printf(
            "sample %02d: hot=%llu cold=%llu delta=%lld\n",
            i,
            (unsigned long long)hot_cycles,
            (unsigned long long)cold_cycles,
            (long long)(cold_cycles - hot_cycles)
        );
    }

    printf(
        "summary: hot_avg=%llu cold_avg=%llu hot_min=%llu cold_min=%llu\n",
        (unsigned long long)(hot_sum / samples),
        (unsigned long long)(cold_sum / samples),
        (unsigned long long)hot_min,
        (unsigned long long)cold_min
    );

    return 0;
}
