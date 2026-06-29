    .option norvc

    .equ SYS_write, 64
    .equ SYS_exit, 93
    .equ SAMPLES, 16

    .section .rodata
label_hot:
    .asciz "hot="
label_cold:
    .asciz " cold="
label_delta:
    .asciz " delta="
label_nl:
    .asciz "\n"
summary_hot:
    .asciz "summary hot_avg="
summary_cold:
    .asciz " cold_avg="
summary_min_hot:
    .asciz " hot_min="
summary_min_cold:
    .asciz " cold_min="

    .section .bss
    .balign 16
print_buf:
    .space 32

    .section .text
    .globl _start
_start:
    li      s0, SAMPLES
    li      s1, 0                  # hot_sum
    li      s2, 0                  # cold_sum
    li      s3, -1
    li      s4, -1                 # hot_min / cold_min start at max uint64

sample_loop:
    beqz    s0, print_summary

    call    warm_target
    call    measure_target_once
    mv      s5, a0                 # hot_cycles

    call    evict_icache
    call    measure_target_once
    mv      s6, a0                 # cold_cycles

    add     s1, s1, s5
    add     s2, s2, s6

    bltu    s5, s3, 1f
    j       2f
1:
    mv      s3, s5
2:
    bltu    s6, s4, 3f
    j       4f
3:
    mv      s4, s6
4:
    la      a0, label_hot
    call    print_cstr
    mv      a0, s5
    call    print_u64

    la      a0, label_cold
    call    print_cstr
    mv      a0, s6
    call    print_u64

    la      a0, label_delta
    call    print_cstr
    sub     a0, s6, s5
    call    print_u64

    la      a0, label_nl
    call    print_cstr

    addi    s0, s0, -1
    j       sample_loop

print_summary:
    la      a0, summary_hot
    call    print_cstr
    li      t0, SAMPLES
    divu    a0, s1, t0
    call    print_u64

    la      a0, summary_cold
    call    print_cstr
    li      t0, SAMPLES
    divu    a0, s2, t0
    call    print_u64

    la      a0, summary_min_hot
    call    print_cstr
    mv      a0, s3
    call    print_u64

    la      a0, summary_min_cold
    call    print_cstr
    mv      a0, s4
    call    print_u64

    la      a0, label_nl
    call    print_cstr

    li      a0, 0
    li      a7, SYS_exit
    ecall

warm_target:
    call    target_window
    ret

measure_target_once:
    rdcycle t0
    call    target_window
    rdcycle t1
    sub     a0, t1, t0
    ret

evict_icache:
    li      t0, 0
    .balign 64
evict_stream:
    .rept 16384
    addi    t0, t0, 1
    .endr
    ret

    .balign 64
target_window:
    addi    t1, zero, 1
    slli    t1, t1, 1
    xori    t1, t1, 3
    addi    t1, t1, 5
    slli    t1, t1, 1
    xori    t1, t1, 7
    addi    t1, t1, 9
    slli    t1, t1, 1
    xori    t1, t1, 11
    addi    t1, t1, 13
    slli    t1, t1, 1
    xori    t1, t1, 15
    addi    t1, t1, 17
    slli    t1, t1, 1
    xori    t1, t1, 19
    addi    t1, t1, 21
    ret

print_cstr:
    mv      t0, a0
1:
    lbu     t1, 0(t0)
    beqz    t1, 2f
    addi    t0, t0, 1
    j       1b
2:
    sub     a2, t0, a0
    mv      a1, a0
    li      a0, 1
    li      a7, SYS_write
    ecall
    ret

print_u64:
    la      t0, print_buf
    addi    t0, t0, 31
    li      t1, 0
    sb      t1, 0(t0)
    mv      t2, a0
    bnez    t2, 1f
    addi    t0, t0, -1
    li      t1, '0'
    sb      t1, 0(t0)
    j       3f
1:
    li      t3, 10
2:
    remu    t4, t2, t3
    divu    t2, t2, t3
    addi    t4, t4, '0'
    addi    t0, t0, -1
    sb      t4, 0(t0)
    bnez    t2, 2b
3:
    mv      a0, t0
    call    print_cstr
    ret
