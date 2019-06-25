#Sotiris Karamellios 2237 and Vassilis Samaras 2144
.data
Enter_Value: .asciiz "Please enter the number to process.\n"
Is_A_Power: .asciiz "The number is a power of 2.\n"
Not_A_Power: .asciiz "The number is not a power of 2.\n"
ch_line: .asciiz "\n"
.align 2
Elements: .space 40

.text
.globl main
main:
	li $v0,4
	la $a0,Enter_Value
	syscall	#Print a message to the user asking the number
	
	li $v0,5
	syscall
	add $t0,$v0,$zero #Save the num.
	
	li $v0,4
	la $a0,ch_line
	syscall #Print a new-line.
	
	beqz $t0,not_a_power
	
	not $t1,$t0 #one's complement
	add $t1,$t1,1 #two's complement
	and $t2,$t1,$t0 
	
	bne $t2,$t0,not_a_power

is_a_power:
	li $v0,4
	la $a0,Is_A_Power
	syscall
	j terminate
	
not_a_power:
	li $v0,4
	la $a0,Not_A_Power
	syscall
	
terminate: #termatismos tou programmatos
	li $v0,10
	syscall #TERMINATING
