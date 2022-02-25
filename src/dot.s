.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use
#   a3 (int)  is the stride of arr0
#   a4 (int)  is the stride of arr1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
# Exceptions:
#   - If the length of the array is less than 1,
#     this function terminates the program with error code 36
#   - If the stride of either array is less than 1,
#     this function terminates the program with error code 37
# =======================================================
dot:
	#Prologue
    li t1 1
    blt a2, t1, code_36
    blt a3, t1, code_37
    blt a4, t1, code_37

    addi sp, sp, -20
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    add s0, a0, x0
    add s1, a1, x0
    add s2, a2, x0
    add s3, a3, x0
    add s4, a4, x0

    # t0 is the running sum for the dot product
    li t0, 0
    # t1 is the iteration counter
    li t1, 0
    j loop_start   
    code_36: # length of array < 1
        li a0, 36
        j exit
    code_37: # stride of either array < 1
        li a0, 37
        j exit

loop_start:

	beq t1, s2, loop_end
	# advance a0 by a3 elems
   	mul t2, t1, s3
    slli t2, t2, 2
    add t2, t2, s0
    lw t3, 0(t2)
    # advance a1 by a4 elems
    mul t4, t1, s4
    slli t4, t4, 2
    add t4, t4, s1
    lw t5, 0(t4)
    # sum the elements in the 2 arrays into a0
	mul t6, t3, t5
    add t0, t0, t6
    
	addi t1, t1, 1
    j loop_start

loop_end:
	# Epilogue
	lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    addi sp, sp, 20
	add a0, x0, t0
	ret
