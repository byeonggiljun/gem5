ARCH = arm64
CC = gcc
CFLAGS = -static -O2
LDFLAGS = -lssl -lcrypto
OUT = $(OUTDIR)/aes
OUTDIR = ./
INIT = $(SQUASHFS_ROOT)/sbin/init

.PHONY: all

all: $(OUT)

$(OUT): aes.c
	$(CROSS_COMPILE)$(CC) \
	-DM5 \
	-I /home/byeonggil/project/gem5/include/ \
	-o $@ \
	$(CFLAGS) \
	/home/byeonggil/project/gem5/util/m5/src/abi/$(ARCH)/m5op.S \
	$< \
	$(LDFLAGS)

clean:
	rm -fr $(OUT)
