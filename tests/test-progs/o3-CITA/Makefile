ARCH = riscv
CROSS_COMPILE = riscv64-linux-gnu-
CC = gcc
ARCHFLAGS = -march=rv64gc -mabi=lp64d
CFLAGS = -static -O0
GEM5_ROOT ?= $(abspath ../../..)
OUTDIR = .

.PHONY: all dcache icache single_trace figure3 clean

all: dcache icache single_trace figure3

dcache: dcache_hot_cold_timing_main.c dcache_hot_cold_timing.s
	$(CROSS_COMPILE)$(CC) \
	-I "$(GEM5_ROOT)/include" \
	-o $(OUTDIR)/dcache_hot_cold_timing.o \
	$(ARCHFLAGS) \
	$(CFLAGS) \
	./dcache_hot_cold_timing_main.c \
	./dcache_hot_cold_timing.s \
	"$(GEM5_ROOT)/util/m5/src/abi/$(ARCH)/m5op.S"

icache: icache_hot_cold_timing_main.c icache_hot_cold_timing.s
	$(CROSS_COMPILE)$(CC) \
	-I "$(GEM5_ROOT)/include" \
	-o $(OUTDIR)/icache_hot_cold_timing.o \
	$(ARCHFLAGS) \
	$(CFLAGS) \
	./icache_hot_cold_timing_main.c \
	./icache_hot_cold_timing.s \
	"$(GEM5_ROOT)/util/m5/src/abi/$(ARCH)/m5op.S"

single_trace: addi_pipeline_trace_main.c addi_pipeline_trace.s
	$(CROSS_COMPILE)$(CC) \
	-I "$(GEM5_ROOT)/include" \
	-o $(OUTDIR)/addi_pipeline_trace.o \
	$(ARCHFLAGS) \
	$(CFLAGS) \
	./addi_pipeline_trace_main.c \
	./addi_pipeline_trace.s \
	"$(GEM5_ROOT)/util/m5/src/abi/$(ARCH)/m5op.S"

figure3: figure3_dependencies_main.c figure3_dependencies.s
	$(CROSS_COMPILE)$(CC) \
	-o $(OUTDIR)/figure3_dependencies.o \
	$(ARCHFLAGS) \
	$(CFLAGS) \
	./figure3_dependencies_main.c \
	./figure3_dependencies.s

clean:
	rm -f $(OUTDIR)/dcache_hot_cold_timing.o $(OUTDIR)/icache_hot_cold_timing.o $(OUTDIR)/addi_pipeline_trace.o $(OUTDIR)/figure3_dependencies.o
