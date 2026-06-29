    .section .data
    .globl hot_line
    .balign 64
hot_line:
    .dword 0x0123456789abcdef

    .globl evict_buf
    .balign 64
evict_buf:
    .space 131072          # 128 KiB: 보통 L1 D-cache보다 크게 잡음
evict_buf_end:

    .section .text
    .globl preload_hot
preload_hot:
    # a0 = &hot_line
    ld      t0, 0(a0)      # hot_line을 cache에 올림
    ret

    .globl evict_hot
evict_hot:
    # a1 = &evict_buf
    mv      t0, a1
    la      t1, evict_buf_end
1:
    ld      t2, 0(t0)       # evict_buf의 다른 line들을 순회하며 hot_line eviction 유도
    addi    t0, t0, 64     # cache line size에 맞춰 stride
    bltu    t0, t1, 1b
    ret

    .globl window_body
window_body:
    # a0 = &hot_line
    # a2 = 반복 횟수
1:
    ld      t0, 0(a0)       # 이 load가 hit냐 miss냐가 핵심
    addi    t1, t0, 1
    xor     t2, t1, t0
    addi    t3, t2, 7
    addi    a2, a2, -1
    bnez    a2, 1b
    ret
