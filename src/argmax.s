.globl argmax

.text
# =================================================================
# FUNCTION: Given a int array, return the index of the largest
#   element. If there are multiple, return the one
#   with the smallest index.
# Arguments:
#   a0 (int*) is the pointer to the start of the array
#   a1 (int)  is the # of elements in the array
# Returns:
#   a0 (int)  is the first index of the largest element
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
# =================================================================
argmax:
    # Prologue
    addi sp, sp, -12
    sw s2, 8(sp)
    sw s1, 4(sp)
    sw s0, 0(sp)
    li t0, 0
    li s0, 0
    lw s1, 0(a0)
    blt x0, a1, loop_start
    li a0, 36
    j exit

loop_start:
    beq t0, a1, loop_end
    slli t1, t0, 2
    add t2, a0, t1
    lw s2, 0(t2)
    bgt s2, s1, loop_continue
    addi t0, t0, 1
    j loop_start
    
loop_continue:
    add s0, x0, t0
    add s1, x0, s2
    addi t0, t0, 1
    j loop_start
    
loop_end:
    add a0, x0, s0

    # Epilogue
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    addi sp, sp 12
    ret
