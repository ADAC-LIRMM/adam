        .section .lpmem.text.lpcpu_start
        .align  2
        .global  lpcpu_start
lpcpu_start:
        la      sp, _elpmem
        la      gp, _global_pointer
        mv      tp, zero
        mv      t1, zero
        mv      t2, zero
        mv      s0, zero
        mv      s1, zero
        mv      a1, zero
        mv      a2, zero
        mv      a3, zero
        mv      a4, zero
        mv      a5, zero
        mv      a6, zero
        mv      a7, zero
        mv      s2, zero
        mv      s3, zero
        mv      s4, zero
        mv      s5, zero
        mv      s6, zero
        mv      s7, zero
        mv      s8, zero
        mv      s9, zero
        mv      s10, zero
        mv      s11, zero
        mv      t3, zero
        mv      t4, zero
        mv      t5, zero
        mv      t6, zero

        la      t0, .lpmem.vectors
        or      t0, t0, 1          # Set MODE=1 for vectored interrupts
        csrw    mtvec, t0

        li      t1, 1
        slli    t2, t1, 3          # Interrupt Enable (MIE)
        csrs    mstatus, t2
        slli    t2, t1, 11         # Machine External Interrupt Enable (MEIE)
        csrs    mie, t2

        call    main_lpcpu

1:
        j       1b

# =============================================================================

        .section .lpmem.text.lpcpu_handler
        .align  2
        .weak   lpcpu_handler
        .type   lpcpu_handler, %function
lpcpu_handler:
1:
        j       1b

# =============================================================================

        .section .lpmem.vectors, "ax"
        .option norvc
        .org    0x00
        j       lpcpu_start
        .rept   10
        j       lpcpu_handler
        .endr
        j       lpcpu_handler
        .rept   4
        j       lpcpu_handler
        .endr
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        j       lpcpu_handler
        .org    0x80
        j       lpcpu_start
        .org    0x84
        j       lpcpu_handler
        .org    0x88
        j       lpcpu_handler

