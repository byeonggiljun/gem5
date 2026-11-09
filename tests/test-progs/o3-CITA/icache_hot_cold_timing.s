    .section .text
    .extern m5_reset_stats
    .extern m5_rpns

    .globl evict_target_window
    .globl benchmark_icache

    .macro target_payload reg
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    addi    \reg, zero, 1
    # slli    \reg, \reg, 1
    # xori    \reg, \reg, 3
    # addi    \reg, \reg, 5
    # slli    \reg, \reg, 1
    # xori    \reg, \reg, 7
    # addi    \reg, \reg, 9
    # slli    \reg, \reg, 1
    # xori    \reg, \reg, 11
    # addi    \reg, \reg, 13
    # slli    \reg, \reg, 1
    # xori    \reg, \reg, 15
    # addi    \reg, \reg, 17
    # slli    \reg, \reg, 1
    # xori    \reg, \reg, 19
    # addi    \reg, \reg, 21
    .endm

    .balign 64
benchmark_icache:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sd      s1, 8(sp)
    sd      s2, 0(sp)

    mv      s0, a0
    mv      s1, a1

    # Warm the exact hot target block before timing it.
    li      s2, 0
    j       target_window_hot

after_warm_hot:
    li      a0, 0
    li      a1, 0
    call    m5_reset_stats
    call    m5_rpns
    mv      s2, a0

    j       target_window_hot

after_hot:
    beqz    s2, after_warm_hot
    call    m5_rpns
    sub     t0, a0, s2
    sd      t0, 0(s0)

    call    evict_target_window

    li      a0, 0
    li      a1, 0
    call    m5_reset_stats
    call    m5_rpns
    mv      s2, a0

    j       target_window_cold

after_cold:
    call    m5_rpns
    sub     t0, a0, s2
    sd      t0, 0(s1)

    ld      s2, 0(sp)
    ld      s1, 8(sp)
    ld      s0, 16(sp)
    ld      ra, 24(sp)
    addi    sp, sp, 32
    ret

    # Hot and cold targets are distinct code blocks with identical payloads.
    # This keeps control flow direct while allowing the cold block to be
    # specifically evicted by same-set conflict lines below.
    .balign 4096
target_window_hot:
    target_payload t1
    j       after_hot

    .balign 4096
target_window_cold:
    target_payload t1
    j       after_cold

    .balign 64
evict_target_window:
    j       evict_line_0

    # 4 KiB spacing preserves the set index for a 64 B line / 64 set L1I.
    # These 9 lines are intended to evict the cold target block by set conflict.
    .balign 4096
evict_line_0:
    addi    t0, t0, 1
    j       evict_line_1

    .balign 4096
evict_line_1:
    addi    t0, t0, 1
    j       evict_line_2

    .balign 4096
evict_line_2:
    addi    t0, t0, 1
    j       evict_line_3

    .balign 4096
evict_line_3:
    addi    t0, t0, 1
    j       evict_line_4

    .balign 4096
evict_line_4:
    addi    t0, t0, 1
    j       evict_line_5

    .balign 4096
evict_line_5:
    addi    t0, t0, 1
    j       evict_line_6

    .balign 4096
evict_line_6:
    addi    t0, t0, 1
    j       evict_line_7

    .balign 4096
evict_line_7:
    addi    t0, t0, 1
    j       evict_line_8

    .balign 4096
evict_line_8:
    addi    t0, t0, 1
    ret
