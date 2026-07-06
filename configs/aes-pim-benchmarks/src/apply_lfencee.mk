M5_UTIL    := $(CURDIR)/../../../util/m5
M5_INCLUDE := $(CURDIR)/../../../include

CFLAGS = -static -O2
LFENCE_CFLAGS = -Wa,-mlfence-after-load=yes \
                -Wa,-mlfence-before-indirect-branch=all \
                -Wa,-mlfence-before-ret=yes
LDFLAGS = -lssl -lcrypto

all: aes

# Direct compilation for x86 host
aes: aes.c
	gcc -I $(M5_INCLUDE) \
		-c $(M5_UTIL)/src/abi/x86/m5op.S \
		-o m5op.o
	gcc -DM5 \
		-I $(M5_INCLUDE) \
		-o aes \
		$(CFLAGS) \
		$(LFENCE_CFLAGS) \
		aes.c \
		m5op.o \
		$(LDFLAGS)

clean:
	rm -f aes m5op.o