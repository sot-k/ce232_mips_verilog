#Sotiris Karamellios 2237 and Vassilis Samaras 2144
.data
Enter_Value: .asciiz "Please enter a positive integer to process.\n"
ch_line: .asciiz "\n"
Num: .asciiz "Number "
positive: .asciiz " is a power of two.\n"
negative: .asciiz " is not a power of two.\n"

.text
.globl main
main:
	li $v0,4
	la $a0,Enter_Value
	syscall
	
	li $v0,5
	syscall
	add $t1,$v0,$zero
	
	li $v0,4
	la $a0,ch_line
	syscall
	
	jal isPow
	
	NotPoTwo: #If the number is not a power of two
	li $v0,4
	la $a0,Num
	syscall
	
	add $a0,$t1,$zero
	li $v0,1
	syscall
	
	li $v0,4
	la $a0,negative
	syscall
	j terminate
	
	PoTwo: #If the number is a power of two
	li $v0,4
	la $a0,Num
	syscall
	
	add $a0,$t1,$zero
	li $v0,1
	syscall
	
	li $v0,4
	la $a0,positive
	syscall
	
	terminate: #terminating the programm
	li $v0,10
	syscall #TERMINATING
	
	isPow:
		li $s0,1 #We insert num 1 to the register $s0
		
		slide: #We shift the register $s0 to the left. This is equal to multiplying by 2. So now we have all the powers of two in $s0.
		beq $s0,$t1,PoTwo #If the number that the user entered is equal to $s0 that means that the num is a power of two.
		sll $s0,$s0,1
		bge $t1,$s0,slide
		
	jr $ra #we jump back where our "procedure" like code was called. This also means that our num is not a power of two.
