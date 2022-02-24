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
    addi sp, sp, -12
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw ra, 8(sp)
	li t1 1
    blt a2, t1, code_36
	blt a3, t1, code_37
    blt a4, t1, code_37
    j loop_start   
    code_36: # length of array < 1
        li a0, 36
        j exit
    code_37: # stride of either array < 1
        li a0, 37
        j exit

loop_start:
	beq t1, a2, loop_end
	# advance a0 by a3 elems
    slli t2, a3, 2
    mul t2, t2, t1
    add t2, t2, a0
    lw s0, 0(t2)
    # advance a1 by a4 elems
    slli t3, a3, 2
    mul t3, t3, a4
    add t6, t3, a1
    lw s1, 0(t6)
    # sum the elements in the 2 arrays into a0
	mul t4, s0, s1
    add t0, t0, t4


	addi t1, t1, 1
    j loop_start

loop_end:
	# Epilogue
	lw s0, 0(sp)
    lw s1, 4(sp)
    lw ra, 8(sp)
    addi sp, sp, 12
	add a0, x0, t0
	ret
