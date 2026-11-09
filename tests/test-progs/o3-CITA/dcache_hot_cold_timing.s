    .section .data
    .globl hot_line
    .balign 4096
hot_line:
    .dword 0x0123456789abcdef

    .balign 4096
evict_buf_0:
    .space 4096     # 8 * 4 KiB = 32 KiB eviction region
evict_buf_1:
    .space 4096
evict_buf_2:
    .space 4096
evict_buf_3:
    .space 4096
evict_buf_4:
    .space 4096
evict_buf_5:
    .space 4096
evict_buf_6:
    .space 4096
evict_buf_7:
    .space 4096

    .section .text
    .globl preload_hot
preload_hot:
    # a0 = &hot_line
    ld      t0, 0(a0)
    ret

    .globl evict_hot
evict_hot:
    la      t1, evict_buf_0
    ld      t2, 0(t1)
    la      t1, evict_buf_1
    ld      t2, 0(t1)
    la      t1, evict_buf_2
    ld      t2, 0(t1)
    la      t1, evict_buf_3
    ld      t2, 0(t1)
    la      t1, evict_buf_4
    ld      t2, 0(t1)
    la      t1, evict_buf_5
    ld      t2, 0(t1)
    la      t1, evict_buf_6
    ld      t2, 0(t1)
    la      t1, evict_buf_7
    ld      t2, 0(t1)
    ret

    .globl window_body
window_body:
    # a0 = &hot_line
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
    ld      t0, 0(a0)
    ret

# .globl test_function
# test_function:
#     addi t0, t0, 1
#     ret

