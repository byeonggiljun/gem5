# O3 cache timing and pipeline probes

These RISC-V programs provide baseline cache-timing measurements and pipeline
traces for timing-anomaly experiments. They do not yet deliberately construct a
timing anomaly. Each executable uses a `.o` suffix and has a matching `_main.c`
driver and `.s` payload with the same base name.

| Executable | Behavior | Previous name |
| --- | --- | --- |
| `dcache_hot_cold_timing.o` | Times a single `addi`, then compares the same load window after warming its data line and after eight conflict loads. | `gen_dcache_anomaly` |
| `icache_hot_cold_timing.o` | Warms and times one instruction block, executes nine conflict blocks, then times a distinct, previously unwarmed block. | `gen_icache_anomaly` |
| `addi_pipeline_trace.o` | Executes six uncompressed `addi` instructions and returns; runtime debug flags provide the trace. | `single_instruction_trace` |
| `figure3_dependencies.o` | Executes five uncompressed adds with dependencies `i0 -> i1` and `i2 -> i3`, then stores and prints their results. | New |

The cache programs print `ns1` (hot) and `ns2` (cold) in simulated nanoseconds.
The D-cache program's initial output says "ticks", but also uses nanoseconds.
The cold I-cache target can miss in both L1I and L2 on its first access. Timings
include control-flow and m5 timing-hook overhead; fetch can begin before the
starting timestamp. Use cache traces to verify hits and misses.

## Build

Use a Linux environment with `riscv64-linux-gnu-gcc` and a runnable
`build/ALL/gem5.opt` supporting RISC-V. Run these commands from the gem5 repository
root:

```bash
make -C tests/test-progs/o3-CITA all
```

Individual targets are `dcache`, `icache`, `single_trace`, and `figure3`. The
Makefile builds static RV64GC executables with `.o` filenames, rather than
relocatable object files. These generated files are ignored by the local
`.gitignore` rule `*.o`. The Makefile locates gem5 headers and m5 operations
relative to this directory; override `GEM5_ROOT` if needed.

## Run

Run each program with the supplied O3 configuration:

```bash
for program in dcache_hot_cold_timing icache_hot_cold_timing addi_pipeline_trace figure3_dependencies; do
  build/ALL/gem5.opt --outdir="m5out/$program" \
    tests/gem5/cpu_tests/run.py \
    --cpu=RiscvDerivO3CPU --mem=SimpleMemory \
    "tests/test-progs/o3-CITA/${program}.o"
done
```

This configuration uses a 1 GHz CPU, 32 KiB / 8-way L1 caches, 64-byte lines,
and a shared 512 KiB / 16-way L2. The 4 KiB conflict-block spacing targets the
same L1 set.

## Observe cache accesses and pipeline timing

Place debug options before the configuration-script path:

```bash
build/ALL/gem5.opt \
  --outdir=m5out/cita-icache \
  --debug-flags=Fetch,Cache,CacheRepl,PseudoInst,O3PipeView \
  --debug-file=trace.log \
  tests/gem5/cpu_tests/run.py \
  --cpu=RiscvDerivO3CPU --mem=SimpleMemory \
  tests/test-progs/o3-CITA/icache_hot_cold_timing.o

rg 'system.cpu.l1i.*(hit|miss)|pseudo_inst::rpns' \
  m5out/cita-icache/trace.log \
  > m5out/cita-icache/filtered_trace.log
```

Replace the binary and output directory to trace another program. For D-cache
accesses, filter `system.cpu.l1d`; inspect `system.l2cache` to distinguish L2 hits
from misses. Fetch logs show virtual instruction addresses, while cache logs show
physical addresses. Fetch's "Waking up from cache miss" message also appears for
hits, so use the cache's explicit `hit` / `miss` records as evidence.

## Figure 3 dependency skeleton

`figure3_dependencies.s` labels the five adds `figure3_i0` through `figure3_i4`.
They read a common input seed and write distinct registers, with only the two
specified producer-consumer dependencies inside the window. For seed 1, the C
wrapper prints `i0=2 i1=3 i2=2 i3=3 i4=2`. Result stores and the return follow the
window; the five adds occupy 20 bytes in one aligned instruction-cache line.

The intended groups are `{i0, i4}` on fu0, `{i1, i2}` on fu1, and `{i3}` on fu2.
All five instructions currently use the same `IntAlu` operation class, so this
initial version leaves FU assignment to gem5 and uses the configured latency.
It reproduces the dependency graph; the two latency cases and exact ROB phases
from Figure 3 are not yet modeled.

```bash
make -C tests/test-progs/o3-CITA figure3
build/ALL/gem5.opt \
  --outdir=m5out/figure3-dependencies \
  --debug-flags=O3PipeView \
  --debug-file=trace.log \
  tests/gem5/cpu_tests/run.py \
  --cpu=RiscvDerivO3CPU --mem=SimpleMemory \
  tests/test-progs/o3-CITA/figure3_dependencies.o
```
