.globl read_matrix

.text
# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
#   - If malloc returns an error,
#     this function terminates the program with error code 26
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fread error or eof,
#     this function terminates the program with error code 29
# ==============================================================================
read_matrix:

	# Prologue
	addi sp, sp, -36
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
	sw s7, 32(sp)
    
	#add s0, x0, a0 #s0 = pointer to string representing filename
    add s1, x0, a1 #s1 = pointer to integer with number of rows
    add s2, x0, a2 #s2 = pointer to integer with number of columns
    
    add a1, x0, x0 #set a1 = 0 for fopen
    jal fopen
    #checking for fopen error
    addi t0, x0, -1
    bne a0, t0, no_fileopen_error
    addi a0, x0, 27
    j exit
    
    no_fileopen_error:
    add s0, a0, x0 #s0 = file descriptor
    
    #prepping to call fread
    add a1, x0, s1
    addi a2, x0, 4
    jal fread
    #checking for fread error
    addi t0, x0, 4
    beq a0, t0, no_fread_error
    addi a0, x0, 29
    j exit
    
    no_fread_error:
    #prepping to call fread Part 2 Electric Boogaloo
    add a0, x0, s0
    add a1, x0, s2
    addi a2, x0, 4
    jal fread
    #checking for fread error Part 2
    addi t0, x0, 4
    beq a0, t0, no_fread_error2
    addi a0, x0, 29
    j exit
    
    no_fread_error2:
    #prepping to call malloc
    lw t0, 0(s1) #number of rows
    lw t1, 0(s2) #number of columns
    mul t2, t0, t1
    slli s3, t2, 2 #s3 = space needed for matrix in bytes
    add a0, x0, s3
    jal malloc
    #check for malloc error
    bne a0, x0, no_malloc_error
    addi a0, x0, 26
    j exit
    
    no_malloc_error:
    add s4, x0, a0 #s4 = pointer to matrix
    #prepping to fread for a THIRD time
    add a0, x0, s0
    add a1, x0, s4
    add a2, x0, s3
    jal fread
    #checking for fread error Part 3
    add t0, x0, s3
    beq a0, t0, no_fread_error3
    addi a0, x0, 29
    j exit
    
    no_fread_error3:
    #prepping to call fclose
    add a0, x0, s0
    jal fclose
    #checking for fclose error
    addi t0, x0, -1
    bne a0, t0, no_fclose_error
    addi a0, x0, 28
    j exit
    
    no_fclose_error:
    add a0, x0, s4

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
    addi sp, sp, 36

	ret
