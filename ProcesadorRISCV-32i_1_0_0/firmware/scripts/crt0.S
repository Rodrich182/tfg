.section .init
.globl _start
.type _start, @function

_start:
    la sp, __stack_top

    la t0, __data_load
    la t1, __data_start
    la t2, __data_end

copy_data_loop:
    bgeu t1, t2, zero_bss
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    beq x0, x0, copy_data_loop

zero_bss:
    la t1, __bss_start
    la t2, __bss_end

zero_bss_loop:
    bgeu t1, t2, call_main
    sw x0, 0(t1)
    addi t1, t1, 4
    beq x0, x0, zero_bss_loop

call_main:
    jal ra, main

halt_forever:
    beq x0, x0, halt_forever

.size _start, . - _start
