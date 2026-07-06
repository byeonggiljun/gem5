M5_UTIL    := $(CURDIR)/../../../util/m5
M5_INCLUDE := $(CURDIR)/../../../include

CFLAGS = -static -O2 -fcf-protection=none
SPECTRE_CFLAGS = -mindirect-branch=thunk \
                 -mfunction-return=thunk \
                 -mindirect-branch-register
LDFLAGS = -lssl -lcrypto

all: aes_no_branches

# Direct compilation for x86 host
aes_no_branches: aes.c
	gcc -I $(M5_INCLUDE) \
		-c $(M5_UTIL)/src/abi/x86/m5op.S \
		-o m5op.o
	gcc -DM5 \
		-I $(M5_INCLUDE) \
		-o aes_no_branches \
		$(CFLAGS) \
		$(SPECTRE_CFLAGS) \
		aes.c \
		m5op.o \
		$(LDFLAGS)

clean:
	rm -f aes_no_branches