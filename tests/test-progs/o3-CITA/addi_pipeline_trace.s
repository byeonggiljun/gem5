    .section .text
    .option norvc
    .globl single_instruction_trace
    .balign 64
single_instruction_trace:
    # Use non-zero addi pairs so the disassembler shows them unambiguously.
    addi    t5, t5, 1
    addi    t5, t5, -1
    addi    t5, t5, 1
    addi    t0, t0, 1
    addi    t5, t5, -1
    addi    t5, t5, 1
    ret
