#include <stdint.h>
#include <stdio.h>
extern void single_instruction_trace(void);

int
main(void)
{
    /*
     * Tracing is controlled by gem5 runtime flags, not by the binary itself.
     * Example:
     * build/ALL/gem5.opt --debug-flags=O3PipeView,Fetch,Decode,Rename,IEW,Commit
     *   tests/gem5/cpu_tests/run.py --cpu=RiscvDerivO3CPU --mem=SimpleMemory
     *   tests/test-progs/o3-CITA/single_instruction_trace
     */
    single_instruction_trace();
    return 0;
}
