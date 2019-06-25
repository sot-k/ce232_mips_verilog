.data
Main_String: .asciiz "Please give string: "
Sub_String: .asciiz "Please give substring: "
Max_Length: .asciiz "The max substring has lengrh: "

#$t5 mikos string
#$t6 mikos substring
.text
.globl main

main:

#printing message to give string
li $v0,4
la $a0,Main_String
syscall

#reading and storing string
li $v0,8
li $a1,20
syscall

la $t0,($a0)# $t0 has string

#printing message to give substring
li $v0,4
la $a0,Sub_String
syscall

#reading and storing substring
li $v0,8
li $a1,20
syscall

la $a1,($a0)# $a1 has substring
la $a0,($t0)# $a0 has string

jal lab2_func
move $s0,$v0

li $v0,4
la $a0,Max_Length
syscall

li $v0,1
move $a0,$s0
syscall

terminate:
li $v0,10
syscall


lab2_func: # our function is a "leef" function so we dont have to push $ra in stack

addi $sp,$sp,-8
sw $s0,0($sp)
sw $s1,4($sp)

la $t0,($a0)# $t0 has string
la $t1,($a1)# $t0 has substring

la $t7,($t0)
add $t5,$zero,$zero #initialize counter to zero. $t5 has string strlen

string_strlen:
lb $t2,0($t7)#load next word
beqz $t2,exit_strlen #checking for NULL
add $t5,$t5,1
add $t7,$t7,1
j string_strlen
exit_strlen:
addi $t5,$t5,-1#removing NULL from counter


la $t7,($t1)
add $t6,$zero,$zero#initialize counter to zero, $t6 has substring strlen

substring_strlen:
lb $t2,0($t7)#load next word
beqz $t2,exit_substrlen #checking for NULL
add $t6,$t6,1
add $t7,$t7,1
j substring_strlen
exit_substrlen:
addi $t6,$t6,-1#removing NULL from counter

add $t8,$zero,$zero #initialize loop counter
add $t9,$zero,$zero #initialize sinexomena current
add $s1,$zero,$zero

la $t7,($t1)

loop:
bge $t9,$t6,return_max #t8 anti t9
bgt $s1,$t5,return_max

lb $t2,($t7) 
lb $t3,($t0)

xor $t4,$t2,$t3
bnez $t4,den_einai
einai:
add $t9,$t9,1
add $t7,$t7,1
j continue

den_einai:
la $t7,($t1)
#add $t8,$zero,$zero
beqz $t9,continue
bgt $s0,$t9,not_grater
add $s0,$t9,$zero #replacing previous max with current max
not_grater:
add $t9,$zero,$zero #reseting sinexomena counter

continue:
add $s1,$s1,1
add $t0,$t0,1
#add $t8,$t8,1
j loop

return_max:
bgt $s0,$t9,not_max
add $s0,$t9,$zero #replacing previous max with current max
not_max:
move $v0,$s0

lw $s0,0($sp)
lw $s1,4($sp)
addi $sp,$sp,8
jr $ra
