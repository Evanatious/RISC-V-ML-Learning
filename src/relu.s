.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
#   a0 (int*) is the pointer to the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   None
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# ==============================================================================
relu:
    # Prologue
    addi sp, sp, -12
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)
    li t0, 0
    add s0, x0, a0
    blt x0, a1, loop_start
    li a0 36
    j exit

loop_start:
    beq t0, a1, loop_end
    slli t1, t0, 2
    add s1, s0, t1
    lw s2, 0(s1)
    blt s2, x0, loop_continue
    addi t0, t0, 1
    j loop_start
    
loop_continue:
    sw x0, 0(s1)
    addi t0, t0, 1
    j loop_start

loop_end:

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp, 12
    
    ret
