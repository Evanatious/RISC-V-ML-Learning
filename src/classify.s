.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>
classify:

	# Prologue
    addi sp, sp, -52
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
    sw s10, 44(sp)
    sw s11, 48(sp)
    
    # save the stuff we want to save
    mv s0, a1 # s0 has argv
    mv s1, a2 # s1 has silent mode
    
    # Check that there are the correct number of command-line arguments
    li t0, 5
    beq a0, t0, correct_num_args
    li a0, 31
    j exit
    correct_num_args:

	# Read pretrained m0
    li a0, 4
    jal malloc # malloc for read_matrix a1
    beq a0, x0, malloc_error
    mv s2, a0
    li a0, 4
    jal malloc # malloc for read_matrix a2
    beq a0, x0, malloc_error
    mv s3, a0
    # set up arguments for read_matrix
    lw a0, 4(s0) # acesss m0 == a1[1]
	mv a1, s2
    mv a2, s3
	jal read_matrix
    mv s4, a0 # s4 has m0 (a pointer to the matrix in memory)
    # free memory and just keep the values
    lw s11, 0(s2) # gonna overwrite s11 later, using it as a temp rn
    mv a0, s2
    jal free
    mv s2, s11 # s2 is num rows of m0
    lw s11, 0(s3)
    mv a0, s3
    jal free
    mv s3, s11 # s3 is num cols of m0
    
	# Read pretrained m1
	li a0, 4
    jal malloc # malloc for read_matrix a1
    beq a0, x0, malloc_error
    mv s5, a0
    li a0, 4
    jal malloc # malloc for read_matrix a2
    beq a0, x0, malloc_error
    mv s6, a0
    # set up arguments for read_matrix
    lw a0, 8(s0) # acesss m1 == a1[2]
	mv a1, s5
    mv a2, s6
	jal read_matrix
    mv s7, a0 # s7 has m1 (a pointer to the matrix in memory)
    # free memory and just keep the values
    lw s11, 0(s5) # gonna overwrite s11 later, using it as a temp rn
    mv a0, s5
    jal free
    mv s5, s11 # s5 is num rows of m1
    lw s11, 0(s6)
    mv a0, s6
    jal free
    mv s6, s11 # s6 is num cols of m1

	# Read input matrix
	li a0, 4
    jal malloc # malloc for read_matrix a1
    beq a0, x0, malloc_error
    mv s8, a0
    li a0, 4
    jal malloc # malloc for read_matrix a2
    beq a0, x0, malloc_error
    mv s9, a0
    # set up arguments for read_matrix
    lw a0, 12(s0) # acesss input matrix == a1[3]
	mv a1, s8
    mv a2, s9
	jal read_matrix
    mv s10, a0 # s10 has input matrix (a pointer to the matrix in memory)
    # free memory and just keep the values
    lw s11, 0(s8) # gonna overwrite s11 later, using it as a temp rn
    mv a0, s8
    jal free
    mv s8, s11 # s8 is num rows of input matrix
    lw s11, 0(s9)
    mv a0, s9
    jal free
    mv s9, s11 # s9 is num cols of input matrix

	# at this point we have loaded all of our matrices and have the dimensions of each of them saved

	# Compute h = matmul(m0, input)
    # need to malloc rows of m0 * cols of input * 4
	mul t0, s2, s9
    slli a0, t0, 2
    jal malloc
    beq a0, x0, malloc_error
    mv s11, a0 # s11 contains a pointer to h
    # set up arguments for matmul
    mv a0, s4
    mv a1, s2
    mv a2, s3
    mv a3, s10
    mv a4, s8
    mv a5, s9
    mv a6, s11
    jal matmul # now s11 contains h

	# Compute h = relu(h)
    mv a0, s11
    mul a1, s2, s9
    jal relu

	# done with m0 so s4 all free now
    mv a0, s4
    jal free
	
    # Compute o = matmul(m1, h)
    # malloc rows of m1 * cols of h (cols of h == cols of input)
	mul t0, s5, s9
    slli a0, t0, 2
    jal malloc
    beq a0, x0, malloc_error
    mv s4, s0 # s4 contains a pointer to o
    # set up arguments for matmul
    mv a0, s7
    mv a1, s5
    mv a2, s6
    mv a3, s11
    mv a4, s2 # rows of h is the same as rows of m0
    mv a5, s9 # cols of h is the same as cols of input matrix
    mv a6, s4
    jal matmul # s4 has o
    
    # done with m1 and input matrix, and h so can free now
    mv a0, s7
    jal free
    mv a0, s10
    jal free
    mv a0, s11
    jal free

	# Write output matrix o into a1[4]
    lw a0, 16(s0)
    mv a1, s4
    mv a2, s5 # num rows of m1
    mv a3, s9 # num cols of h
    jal write_matrix
	
	# Compute and return argmax(o)
	mv a0, s4
    mul a1, s5, s9
    jal argmax
    mv s2, a0 # 99.99% sure we're not using s2

	# If enabled, print argmax(o) and newline
    li t0, 1
	beq s1, t0, no_print
    mv a0, s2
    jal print_int
    li a0, '\n'
    jal print_char
    no_print:
    
    # free EVERYTHING (I think just o at this point)
    mv a0, s4
    jal free

	# Epilogue
    addi sp, sp, 52
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
    lw s10, 44(sp)
    lw s11, 48(sp)
	ret
    
    malloc_error:
    li a0, 26
    j exit
