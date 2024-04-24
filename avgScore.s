.data 

orig: .space 100	# In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100
space: .asciiz " "
nextLine: .asciiz "\n"

str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "


.text 

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.
main: 
	addi $sp, $sp -4
	sw $ra, 0($sp)
	li $v0, 4 
	la $a0, str0 
	syscall 
	li $v0, 5	# Read the number of scores from user
	syscall
	move $s0, $v0	# $s0 = numScores
	move $t0, $0
	la $s1, orig	# $s1 = orig
	la $s2, sorted	# $s2 = sorted
loop_in:
	li $v0, 4 
	la $a0, str1 
	syscall 
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	li $v0, 5	# Read elements from user
	syscall
	sw $v0, 0($t1)
	addi $t0, $t0, 1
	bne $t0, $s0, loop_in
	
	move $a0, $s0
	jal selSort	# Call selSort to perform selection sort in original array
	
	li $v0, 4 
	la $a0, str2 
	syscall
	move $a0, $s1	# More efficient than la $a0, orig
	move $a1, $s0
	jal printArray	# Print original scores
	li $v0, 4 
	la $a0, str3 
	syscall 
	move $a0, $s2	# More efficient than la $a0, sorted
	jal printArray	# Print sorted scores
	
	li $v0, 4 
	la $a0, str4 
	syscall 
	li $v0, 5	# Read the number of (lowest) scores to drop
	syscall
	move $a1, $v0
	sub $a1, $s0, $a1 # numScores - drop
	move $a0, $s2
	jal calcSum  # Call calcSum to RECURSIVELY compute the sum of scores that are not dropped
	
	
	
	####################################################
	# Your code here to compute average and print it
	#computes avg by pre-calculates sum in ($v0) and element count ($a1) and prints result
	
	# Prepare to print msg before showing the average
	move $t0, $v0          # Copy sum from $v0 to $t0 for division
	li $v0, 4              # $v0 to 4 to print string 
	la $a0, str5           # Load address of the msg string into $a0
	syscall                

	# average compute
	div $t0, $t0, $a1      # Divide sum in $t0 by count in $a1 for avg
	move $a0, $t0          # Move avg into $a0 for print

	# computed average print
	li $v0, 1              # $v0 to 1 to print integer syscall
	syscall                
	####################################################
	
	lw $ra, 0($sp)
	addi $sp, $sp 4
	li $v0, 10 
	syscall
	



######################################################################	
# printList takes in an array and its size as arguments. 
# It prints all the elements in one line with a newline at the end.

# Your implementation of printList here

# $a0 = address of the array to print, $a1 = number of elements in the array	

printArray:
	move $t5, $a0          # $t5 traverse array initially points to start of array
	move $t6, $0           # $t6 temp store current element to be printed
	move $t7, $0           # $t7 is loop counter initialized to 0

loopin:
	lw $t6, 0($t5)         # Load current array element 
	li $v0, 1              # Syscall printing an integer
	addi $a0, $t6, 0       # Move current element for printing
	syscall                # syscall to print the integer

	li $a0, 32            # Load space ASCII code (32) into $a0
	li $v0, 11  	      # Syscall printing character
	syscall                

	addi $t5, $t5, 4       # Increment array pointer to the next integer (4 bytes per integer)
	addi $t7, $t7, 1       # Increment loop counter
	bne $t7, $a1, loopin   # Continue looping if haven't printed all elements yet
	
	li $a0, 10             # Load newline ASCII code (10) into $a0 for printing newline after array
	li $v0, 11             # printing a character
	syscall                     
######################################################################	
	jr $ra 

		
				
	
						
											
																					
		
																		
######################################################################	
# selSort takes in the number of scores as argument. 
# It performs SELECTION sort in descending order and populates the sorted array

# $a0 = number of elements, $s1 = address of the unsorted array, $s2 = address of the sorted array

# Your implementation of selSort here

selSort:
    move $t0, $0          #index $t0 = 0 array copying
    move $t7, $a0         # number of elements store = $t7.

# Copy array from ($s1) to ($s2)
copy_array:
    sll $t1, $t0, 2       # Calculate offset for current index
    add $t1, $t1, $s1     # Address of current element in source array
    lw $v0, 0($t1)        # Load element at calculated address in $v0
    sll $t2, $t0, 2       # Calculate offset for current index in destination
    add $t2, $t2, $s2     # Address of current element in  destination array
    sw $v0, 0($t2)        # Store loaded element into destination array
    addi $t0, $t0, 1      # Increment index
    bne $t0, $a0, copy_array # Repeat until all elements copied

# Sort array
    move $t0, $0          # Reset index $t0 for sorting
    beq $a0, 1, nosort    # If only one element skip sorting

sort1:
    move $t2, $t0         # $t2 to $t0, $t2 will track index of largest element found
    addi $t1, $t0, 1      # $t1 to $t0 + 1 to compare with  elements

# Inner loop to find largest element in unsorted array segment
sort2:
    sll $t3, $t1, 2       # Address calculation for element at index $t1
    add $t3, $t3, $s2
    lw $t4, 0($t3)        # load element $t3
    sll $t5, $t2, 2       # Address calculation largest element
    add $t5, $t5, $s2
    lw $t6, 0($t5)        # load current largest element

    blt $t4, $t6, sort_else1 # current element is smaller, skip updating $t2

    move $t2, $t1         # $t2 to point to new largest element index

sort_else1:
    addi $t1, $t1, 1      # Increment $t1 to compare  ext element
    bne $t1, $a0, sort2   # Continue loop til all elements compared

# Swap largest element found with first element of unsorted part
    sll $t5, $t2, 2       # Address largest element.
    add $t5, $t5, $s2
    lw $t6, 0($t5)
    sll $t3, $t0, 2       # Address of starting element of unsorted segment
    add $t3, $t3, $s2
    lw $t4, 0($t3)
    sw $t4, 0($t5)        # Swap elements
    sw $t6, 0($t3)

    addi $t0, $t0, 1      # Move to next starting element of unsorted segment.
    addi $t7, $a0, -1     # Decrement loop 
    bne $t0, $t7, sort1   # Repeat sorting process until sorted
	
######################################################################	
nosort: 
	jr $ra


	
		
			

					
										
															
																				
######################################################################																																																													
# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.

# Your implementation of calcSum here
calcSum:
    addi $sp, $sp, -12   # space for 3 items on stack
    sw $ra, 8($sp)       # return address on stack
    sw $a0, 4($sp)       # base address of array on stack
    sw $a1, 0($sp)       # length of array on stack

    slt $t0, $zero, $a1  # $t0 to 1 if $a1 is greater than zero (check for base case)
    beq $t0, $zero, lenisZero # array length = zero, jump to the base case 

    addi $a1, $a1, -1    # Decrement length of array for the recursive call
    jal calcSum          # Recursive call to calcSum with decremented length

    # After returning from recursion, calculate sum of current element and accumulated sum
    lw $t0, 4($sp)       # Restore base address of the array from stack
    sll $t0, $a1, 2      # Calculate memory address offset for current element
    add $t0, $t0, $a0    # Add offset to  base address
    lw $t0, 0($t0)       # Load current array element
    add $v0, $v0, $t0    # Add current element's value to accumulated sum
    j endCalcSum         # Jump to end of the function to perform stack cleanup

lenisZero:               # Base case handler
    li $v0, 0            # array length = zero, set sum to zero

endCalcSum:              
    lw $ra, 8($sp)       # Restore return address from stack
    lw $a0, 4($sp)       # Restore base address of array from stack
    lw $a1, 0($sp)       # Restore length of array from stack
    addi $sp, $sp, 12    # Deallocate stack space
    jr $ra               # Return to caller with sum in $v0
######################################################################   