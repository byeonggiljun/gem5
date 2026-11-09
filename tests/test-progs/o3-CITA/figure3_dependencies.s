    .section .text
    .option norvc
    .globl figure3_dependencies
    .type figure3_dependencies, @function
    .balign 64
figure3_dependencies:
    # a0 = seed; a1 = address of five output values.
    # Only i1 <- i0 and i3 <- i2 have dependencies within this window.
    # Intended FU groups: {i0, i4}: fu0; {i1, i2}: fu1; {i3}: fu2.
    # These are all IntAlu operations: FU assignment and latency are not forced.
figure3_i0:
    add     t0, a0, a0
figure3_i1:
    add     t1, t0, a0
figure3_i2:
    add     t2, a0, a0
figure3_i3:
    add     t3, t2, a0
figure3_i4:
    add     t4, a0, a0

    # Collect results after the five-instruction window.
    sd      t0, 0(a1)
    sd      t1, 8(a1)
    sd      t2, 16(a1)
    sd      t3, 24(a1)
    sd      t4, 32(a1)
    ret
    .size figure3_dependencies, .-figure3_dependencies

    .section .note.GNU-stack,"",@progbits
