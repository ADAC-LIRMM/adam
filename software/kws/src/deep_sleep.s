.data
.global deep_sleep_sp
.align   2
deep_sleep_sp:
    .word    0xDEADBEEF
    .size    deep_sleep_sp, 4


.section .text.deep_sleep, "ax"
.global deep_sleep
.align 2
deep_sleep:

    # Read mstatus
    csrr t0, mtvec
    csrr t1, mstatus
    csrr t2, mie

    # Disable interrupts
    csrrc x0, mstatus, 0x8

    # Register Backup
    addi sp, sp, -128
    # sw x0, 0(sp)
    sw x1, 4(sp)
    # sw x2, 8(sp)
    sw x3, 12(sp)
    sw x4, 16(sp)
    sw x5, 20(sp)
    sw x6, 24(sp)
    sw x7, 28(sp)
    sw x8, 32(sp)
    sw x9, 36(sp)
    sw x10, 40(sp)
    sw x11, 44(sp)
    sw x12, 48(sp)
    sw x13, 52(sp)
    sw x14, 56(sp)
    sw x15, 60(sp)
    sw x16, 64(sp)
    sw x17, 68(sp)
    sw x18, 72(sp)
    sw x19, 76(sp)
    sw x20, 80(sp)
    sw x21, 84(sp)
    sw x22, 88(sp)
    sw x23, 92(sp)
    sw x24, 96(sp)
    sw x25, 100(sp)
    sw x26, 104(sp)
    sw x27, 108(sp)
    sw x28, 112(sp)
    sw x29, 116(sp)
    sw x30, 120(sp)
    sw x31, 124(sp)

    # Backup Stack Pointer
    la t0, deep_sleep_sp
    sw sp, 0(t0)

    la t1, wakeup
    li t2, 0x00008078 # RAL.SYSCFG.CPU[0]->BAR
    sw t1, 0(t2)

    # Trigger Maestro Action
    li t1, 3
    li t2, 0x00008074
    sw t1, 0(t2)
1:
    lw t1, 0(t2)
    bne t1, x0, 1b

# MIRROR LINE ---------------------------------------------------------------- #
.align 2
wakeup:

    la t0, deep_sleep_sp
    lw sp, 0(t0)

    # Register Restore
    # lw x0, 0(sp)
    lw x1, 4(sp)
    # lw x2, 8(sp)
    lw x3, 12(sp)
    lw x4, 16(sp)
    lw x5, 20(sp)
    lw x6, 24(sp)
    lw x7, 28(sp)
    lw x8, 32(sp)
    lw x9, 36(sp)
    lw x10, 40(sp)
    lw x11, 44(sp)
    lw x12, 48(sp)
    lw x13, 52(sp)
    lw x14, 56(sp)
    lw x15, 60(sp)
    lw x16, 64(sp)
    lw x17, 68(sp)
    lw x18, 72(sp)
    lw x19, 76(sp)
    lw x20, 80(sp)
    lw x21, 84(sp)
    lw x22, 88(sp)
    lw x23, 92(sp)
    lw x24, 96(sp)
    lw x25, 100(sp)
    lw x26, 104(sp)
    lw x27, 108(sp)
    lw x28, 112(sp)
    lw x29, 116(sp)
    lw x30, 120(sp)
    lw x31, 124(sp)
    addi sp, sp, 128

    # Restore CSRs
    csrw mtvec, t0
    csrw mstatus, t1
    csrw mie, t2

    # Return
    ret
