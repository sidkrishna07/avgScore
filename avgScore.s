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

printArray:
    move $t0, $0            # index $t0 to 0 to start from first element
    move $t1, $a0           # Store base address of  array in $t1

# Loop iterate over each element of array
print:
    sll $t2, $t0, 2         # Shift  index left by 2 to calculate offset
    add $t2, $t2, $t1       # offset to base address for memory address of current element
    lw $a0, 0($t2)          # Load value of current array element for print
    
    li $v0, 1               #print integer syscall
    syscall                

    li $v0, 4               # print string syscall
    la $a0, space           # space character into $a0
    syscall                 

    addi $t0, $t0, 1        # Increment index to move to next array element
    bne $t0, $a1, print     # Compare index with array size and if not equal then continue print

# print newline character:
    li $v0, 4               # print string syscall
    la $a0, nextLine        # Load address of the newline string 
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

calcSum: 
move $t0, $a2       # numLowestToDrop into $t0
move $t1, $a0       # base address of array into $t1
move $t2, $a1       # length of array into $t2
move $t3, $0        # sum in $t3 to 0
move $s0, $0        # index in $s0 to 0

# Loop through array elements
loop_calc:
    beq $t2, $s0, sum_done    # index equals array length, end loop
    ble $t0, $s0, not_drop    # Continue summing if numLowestToDrop is less than or equal to index
    j drop_next               # Jump to increment index if lowest to drop.

# Summing elements not in the lowest to drop
not_drop:
    sll $t4, $s0, 2           #address offset calculation by shifting index left by 2 
    add $t4, $t4, $t1         # memory address of array element by adding base address and offset
    lw $t5, 0($t4)            # load value array element at index into $t5
    add $t3, $t3, $t5         # Add value of element to sum


drop_next:
    addi $s0, $s0, 1          # Incrementing index

# Return to the loop
    j loop_calc

# End of the loop and output result
sum_done:
    move $v0, $t3             # computed sum to return register
    
######################################################################	
    jr $ra
	
