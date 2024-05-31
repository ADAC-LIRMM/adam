.text
.globl sleep

sleep:

    # Read mstatus
    csrr t0, mstatus

    # Disable interrupts
    csrrc t1, mstatus, 0x8

    # Check for Dirty Floating-Point State  
    li t1, 0x80000000 # SD bit
    and t1, t1, t0 
    beq t1, zero, reg_backup #if not dirty then dont backup

    # Floating-Point Backup
    addi sp, sp, -140
    fsw f0, 0(sp)
    fsw f1, 4(sp)
    fsw f2, 8(sp)
    fsw f3, 12(sp)
    fsw f4, 16(sp)
    fsw f5, 20(sp)
    fsw f6, 24(sp)
    fsw f7, 28(sp)
    fsw f8, 32(sp)
    fsw f9, 36(sp)
    fsw f10, 40(sp)
    fsw f11, 44(sp)
    fsw f12, 48(sp)
    fsw f13, 52(sp)
    fsw f14, 56(sp)
    fsw f15, 60(sp)
    fsw f16, 64(sp)
    fsw f17, 68(sp)
    fsw f18, 72(sp)
    fsw f19, 76(sp)
    fsw f20, 80(sp)
    fsw f21, 84(sp)
    fsw f22, 88(sp)
    fsw f23, 92(sp)
    fsw f24, 96(sp)
    fsw f25, 100(sp)
    fsw f26, 104(sp)
    fsw f27, 108(sp)
    fsw f28, 112(sp)
    fsw f29, 116(sp)
    fsw f30, 120(sp)
    fsw f31, 124(sp)    
    csrr t1, fflags
    sw t1, 128(sp)

    csrr t1, frm
    sw t1, 132(sp)

    csrr t1, fcsr

    #set the mstatus.fs to clean state (mstatus[14:13]=2'b10)
    li t3, 0xffffcfff       # Create a mask with bits 13 and 14 set to 0 and all other bits set to 1
    and t0, t0, t3          # Clear bits 13 and 14
    li t4, 0x00002000       # Create a value with bits 13 set to 1 and bit 14 set to 0
    or t0, t0, t4           # Set bit 13 to 1 while preserving the rest
    csrw mstatus, t0        # Write back the modified value to mstatus

    sw t1, 136(sp)
    
reg_backup:

    # Register Backup
    addi sp, sp, -128
    sw x1, 4(sp)
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
    la t0, _stack_ptr_start
    sw sp, 0(t0)
    # nop 

    # Load Memory Bank Addresses
	li t0, 0x01000000 # RAM
	la t1, 0x02000000 # RAM Backup
	la t2, 0x02008000 # RAM Backup End (16k)
    
# Backup ROM into RAM
# backup_loop:
#     # Backup word
# 	lw t3, 0(t0)
# 	sw t3, 0(t1)
#     
#     # Increment pointers
# 	add t0, t0, 4
# 	add t1, t1, 4
#     
#     # Check for exit condition
# 	ble t1, t2, backup_loop

backup_loop_end:

    # Update SYSCTRL.BAR_CPU0 (Boot Address Register)
    la t1, wakeup
    lui t2, 0x8
    sw t1, 120(t2)

    # Trigger Maestro Action
    li t1, 3
    li t2, 0x00008074
    sw t1, 0(t2)

wait_maestro:
    lw t1, 0(t2)
    bne t1, x0, wait_maestro

# MIRROR LINE ---------------------------------------------------------------- #

wakeup:

    # Retrieve Stack Pointer 
    la t0, _stack_ptr_start
    lw sp, 0(t0)

    # Load Memory Bank Addresses
	li t0, 0x01000000 # RAM
	la t1, _stack_ptr_end # RAM Backup
	la t2, 0x02008000 # RAM Backup End (32k)
    
    # Restore Stack Pointer
    # lw sp, 0(t1)
    # add t1, t1, 4


restore_loop_end:

    # Register Restore
    lw x1, 4(sp)
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

    # Check for Dirty Floating-Point State  
    # li t1, 0x80000000 # SD bit
    # and t1, t1, t0
    # beq t1, zero, fp_restore_end #if it's clean then backup the registers
   
    # Check if mstatus.FS is clean
    csrr t2, mstatus            # Load mstatus into t2
    li t3, 0x00006000           #Create a value with bits 13 and 14 set to 1 and all other bits set to 0
    and t4, t2, t3              # Isolate bits 13 and 14
    li t5, 0x00004000           #Create a value with bit 13 set to 1 and bit 14 set to 0
    bne t4, t5, fp_restore_end  # Compare isolated bits with the expected value

    # Floating-Point Restore
    flw f0, 0(sp)
    flw f1, 4(sp)
    flw f2, 8(sp)
    flw f3, 12(sp)
    flw f4, 16(sp)
    flw f5, 20(sp)
    flw f6, 24(sp)
    flw f7, 28(sp)
    flw f8, 32(sp)
    flw f9, 36(sp)
    flw f10, 40(sp)
    flw f11, 44(sp)
    flw f12, 48(sp)
    flw f13, 52(sp)
    flw f14, 56(sp)
    flw f15, 60(sp)
    flw f16, 64(sp)
    flw f17, 68(sp)
    flw f18, 72(sp)
    flw f19, 76(sp)
    flw f20, 80(sp)
    flw f21, 84(sp)
    flw f22, 88(sp)
    flw f23, 92(sp)
    flw f24, 96(sp)
    flw f25, 100(sp)
    flw f26, 104(sp)
    flw f27, 108(sp)
    flw f28, 112(sp)
    flw f29, 116(sp)
    flw f30, 120(sp)
    flw f31, 124(sp)

    lw t1, 128(sp)
    csrw fflags, t1

    lw t1, 132(sp)
    csrw frm, t1

    lw t1, 136(sp)
    csrw fcsr, t1

    addi sp, sp, 140
fp_restore_end:

    # Write mstatus
    csrw mstatus, t0
    # Return
    ret