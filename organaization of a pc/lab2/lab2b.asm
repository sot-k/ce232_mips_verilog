
.text
.globl main

main:

li $v0,5
syscall

move $t0,$v0

li $v0,5
syscall

move $t1,$v0

li $v0,5
syscall

move $t2,$v0

li $v0,5
syscall

move $t3,$v0


sltu $t4, $t1, $t3 # $v1 = ($a0 < $a2)? 1:0(subtract 1 if there's a borrow for Lo words) t4 kratoumeno
subu $t1, $t1, $t3 # $v0 = $a0 - $a2 
subu $t0, $t0, $t4 # $a1 = $a1 - $v1 
subu $t0, $t0, $t2 # $v1 = $a1 - $a3

move $a0,$t0 # result of high bits
move $a1,$t1 # result of low bits

li $v0,10
syscall