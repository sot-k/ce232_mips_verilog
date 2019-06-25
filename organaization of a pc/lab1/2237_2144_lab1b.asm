#Sotiris Karamellios 2237 and Vassilis Samaras 2144
.data
Enter_Value: .asciiz "Please enter the number of elements to process.\n"
Enter_Search: .asciiz "Please enter the number to search.\n"
Found_Number: .asciiz "The number was found in position : "
Not_Found: .asciiz "The number was not found."
ch_line: .asciiz "\n"
.align 2
Elements: .space 40

.text
.globl main
main:
	li $v0,4
	la $a0,Enter_Value
	syscall	#Print a message to the user asking the number of Elements.
	
	li $v0,5
	syscall
	add $t0,$v0,$zero #Save the num of elements. We will use this value later.
	
	li $v0,4
	la $a0,ch_line
	syscall #Print a new-line.
	
	li $t4,4
	li $t1,0
	for:
	bge $t1,$t0,endfor
	
	li $v0,5
	syscall
	addi $t2,$v0,0
	
	mul  $t3,$t1,4
	sw $t2,Elements($t3)
	
	addi $t1,$t1,1 #increase counter by 1
	j for
endfor:
	li $v0,4
	la $a0,Enter_Search
	syscall	#Print a message to the user asking the number to search.
	
	li $v0,5
	syscall
	add $t2,$v0,$zero #Save the number to search.
	
	add $t4,$zero,$zero #begin
	add $t5,$t0,-1 #end
	
binary_loop:
	bgt $t4,$t5,not_found
	
	add $t3,$t4,$t5 #middle
	sra $t3,$t3,1
	mul $t6,$t3,4
	
	lw $t7,Elements($t6)
	beq $t2,$t7,found
	bgt $t2,$t7,greater
	
less:
	add $t5,$t3,-1
	j binary_loop
	
greater:
	add $t4,$t3,1
	j binary_loop
	
found: #our search found the desired element
	li $v0,4
	la $a0,Found_Number
	syscall	#Print a message to the user informing him that number was found.
	
	li $v0,1
	add $a0,$t3,$zero
	syscall	#Print the position of the found number.
	
	j terminate
	
not_found:
	li $v0,4
	la $a0,Not_Found
	syscall	#Print a message to the user informing him that number was found.
	
terminate: #terminating the programm
	li $v0,10
	syscall #TERMINATING
	
