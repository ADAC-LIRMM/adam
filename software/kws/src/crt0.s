/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

        .section .text._start
        .align  2
        .globl  _start
_start:

        /* Trigger Maestro Resume */
        li      x6, 1
        la      x1, 0x00008094     # MEM0
        sw      x6, 0(x1)
        la      x2, 0x000080a4     # MEM1
        sw      x6, 0(x2)
        la      x3, 0x00008064     # LPMEM
        sw      x6, 0(x3)

_wait_mem0:
        lw      x6, 0(x1)
        bne     x6, x0, _wait_mem0

_wait_mem1:
        lw      x6, 0(x2)
        bne     x6, x0, _wait_mem1

_wait_lpmem:
        lw      x6, 0(x3)
        bne     x6, x0, _wait_lpmem

        # Restore if context saved
        lw   t0, context_sp
        bnez t0, context_restore

        la      sp, _estack
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

        la      t0, .vectors
        or      t0, t0, 1          # Set MODE=1 for vectored interrupts
        csrw    mtvec, t0

        li      t1, 1
        slli    t2, t1, 3          # Interrupt Enable (MIE)
        csrs    mstatus, t2
        slli    t2, t1, 11         # Machine External Interrupt Enable (MEIE)
        csrs    mie, t2

        # Copy mem1_load
        la      a0, _etext
        la      a1, _sdata
        la      a2, _edata
        call    _copy_section

        # Copy lpmem
        la      a1, _slpmem
        la      a2, _elpmem
        call    _copy_section

        la      a0, _sbss
        la      a1, _ebss
        call    _zero_section

        la      a0, __libc_fini_array
        call    atexit

        call    __libc_init_array

        li      a0, 0              # argv
        li      a1, 0              # argc
        li      a2, 0              # envp
        call    main

        li      a1, 0
        call    __call_exitprocs

1:
        j       1b

# =============================================================================
# void _copy_section(void* src, void* dest, void* end)

_copy_section:
        beq     a1, a2, 2f         # if dest == end, nothing to do
1:
        lw      t0, 0(a0)          # t0 = *src
        sw      t0, 0(a1)          # *dest = t0
        addi    a0, a0, 4          # src++
        addi    a1, a1, 4          # dest++
        blt     a1, a2, 1b         # while dest < end
2:
        ret

# =============================================================================
# void _zero_section(void* start, void* end)

_zero_section:
        beq     a0, a1, 2f         # if start == end, nothing to do
1:
        sw      zero, 0(a0)        # *start = 0
        addi    a0, a0, 4          # start++
        blt     a0, a1, 1b         # while start < end
2:
        ret

# =============================================================================

        .section .text.default_handler
        .weak   default_handler
        .type   default_handler, %function
default_handler:
1:
        j       1b

# =============================================================================

        .section .vectors, "ax"
        .option norvc
        .org    0x00
        j       _start
        .rept   10
        j       default_handler
        .endr
        j       default_handler
        .rept   4
        j       default_handler
        .endr
        j       irq_0_handler
        j       irq_1_handler
        j       irq_2_handler
        j       irq_3_handler
        j       irq_4_handler
        j       irq_5_handler
        j       irq_6_handler
        j       irq_7_handler
        j       irq_8_handler
        j       irq_9_handler
        j       irq_10_handler
        j       irq_11_handler
        j       irq_12_handler
        j       irq_13_handler
        j       irq_14_handler
        j       irq_nmi_handler
        .org    0x80
        j       _start
        .org    0x84
        j       default_handler
        .org    0x88
        j       default_handler

        .weak   irq_0_handler
        .weak   irq_1_handler
        .weak   irq_2_handler
        .weak   irq_3_handler
        .weak   irq_4_handler
        .weak   irq_5_handler
        .weak   irq_6_handler
        .weak   irq_7_handler
        .weak   irq_8_handler
        .weak   irq_9_handler
        .weak   irq_10_handler
        .weak   irq_11_handler
        .weak   irq_12_handler
        .weak   irq_13_handler
        .weak   irq_14_handler
        .weak   irq_nmi_handler

        .set    irq_0_handler, default_handler
        .set    irq_1_handler, default_handler
        .set    irq_2_handler, default_handler
        .set    irq_3_handler, default_handler
        .set    irq_4_handler, default_handler
        .set    irq_5_handler, default_handler
        .set    irq_6_handler, default_handler
        .set    irq_7_handler, default_handler
        .set    irq_8_handler, default_handler
        .set    irq_9_handler, default_handler
        .set    irq_10_handler, default_handler
        .set    irq_11_handler, default_handler
        .set    irq_12_handler, default_handler
        .set    irq_13_handler, default_handler
        .set    irq_14_handler, default_handler
        .set    irq_nmi_handler, default_handler
