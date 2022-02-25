.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
#   d = matmul(m0, m1)
# Arguments:
#   a0 (int*)  is the pointer to the start of m0
#   a1 (int)   is the # of rows (height) of m0
#   a2 (int)   is the # of columns (width) of m0
#   a3 (int*)  is the pointer to the start of m1
#   a4 (int)   is the # of rows (height) of m1
#   a5 (int)   is the # of columns (width) of m1
#   a6 (int*)  is the pointer to the the start of d
# Returns:
#   None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 38
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 38
# =======================================================
matmul:

	# Error checks
    addi t0, x0, 1
    blt a1, t0, code_38
    blt a2, t0, code_38
    blt a4, t0, code_38
    blt a5, t0, code_38
    bne a2, a4, code_38
	# Prologue
	addi sp, sp, -44
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    
    add s0, x0, a0
    add s1, x0, a1
    add s2, x0, a2
    add s3, x0, a3
    add s4, x0, a4
    add s5, x0, a5
    add s6, x0, a6
    
    # iteration counter
    li s8 0
    j outer_loop_start
    
    
code_38: # width of m0 != height of m1 || width/height of a matrix < 1
    li a0, 38
  	j exit

outer_loop_start:
	beq s8, s1, outer_loop_end
    li s9 0
    add s7, s3, x0



inner_loop_start:
	beq s9, s5, inner_loop_end
    add a0, s0, x0
    add a1, s7, x0
    add a2, s2, x0
    addi a3, x0, 1
    add a4, s5, x0

	jal ra dot
    sw a0, 0(s6)
    addi s7, s7, 4
    addi s9, s9, 1
    addi s6, s6, 1
    j inner_loop_start



inner_loop_end:
	slli t2, s2, 2
    add s0, s0, t2
    addi s8, s8, 1
	j outer_loop_start


outer_loop_end:


	# Epilogue
	lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    lw s9, 40(sp)
    addi sp, sp, 44

	ret
