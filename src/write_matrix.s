.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
#   - If you receive an fopen error or eof,
#     this function terminates the program with error code 27
#   - If you receive an fclose error or eof,
#     this function terminates the program with error code 28
#   - If you receive an fwrite error or eof,
#     this function terminates the program with error code 30
# ==============================================================================
write_matrix:

	# Prologue
	addi sp, sp, -24
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)

	#add s0, x0, a0 #s0 = pointer to string representing filename
    add s1, x0, a1 #s1 = pointer to matrix
    add s2, x0, a2 #s2 = number of rows
    add s3, x0, a3 #s3 = number of columns
    
    addi a1, x0, 1 #set a1 = 1 for fopen
    jal fopen
    #checking for fopen error
    addi t0, x0, -1
    bne a0, t0, no_fileopen_error
    addi a0, x0, 27
    j exit
    
    no_fileopen_error:
    add s0, a0, x0 #s0 = file descriptor
    
    #prep for malloc for pointer to integer
    addi a0, x0, 4
    jal malloc
	#checking for malloc error
    bne a0, x0, no_malloc_error
    addi a0, x0, 26
    j exit
    
    no_malloc_error:
    add s4, a0, x0 #s4 = pointer to integer
    sw s2, 0(s4) #put number of rows into s4
    #prepping to call fwrite
    add a0, x0, s0
    add a1, x0, s4
    addi a2, x0, 1
    addi a3, x0, 4
    jal fwrite
    #checking for fwrite error
    addi t0, x0, 1
    beq a0, t0, no_fwrite_error
    addi a0, x0, 30
    j exit
    
    no_fwrite_error:
    sw s3, 0(s4) #put number of rows into s4
    #prepping to call fwrite Part 2
    add a0, x0, s0
    add a1, x0, s4
    addi a2, x0, 1
    addi a3, x0, 4
    jal fwrite
    #checking for fwrite error Part 2
    addi t0, x0, 1
    beq a0, t0, no_fwrite_error2
    addi a0, x0, 30
    j exit
    
    no_fwrite_error2:
    #prepping for fwrite Part 3
    add a0, x0, s0
    add a1, x0, s1
    mul a2, s2, s3
    addi a3, x0, 4
    jal fwrite
	#checking for fwrite error Part 3
    mul t0, s2, s3
    beq a0, t0, no_fwrite_error3
    addi a0, x0, 30
    j exit

	no_fwrite_error3:
	add a0, x0, s0
    jal fclose
    #checking for fclose error
    beq a0, x0, no_fclose_error
    addi a0, x0, 28
    j exit

	no_fclose_error:

	# Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    addi sp, sp, 24

	ret
