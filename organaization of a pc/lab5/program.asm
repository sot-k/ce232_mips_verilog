.text
.globl main            		# label "main" must be global

main:

# number to guess
add $t0, $t0, $s0
sub $t1, $t1, $a0
or $t7, $t7, $t5
and $s1, $s0, $s2
nop
label: add $t1, $t0, $a0
sw $t1, 0($t3)          
lw $s2, 0($t3)        
slt $t1, $t0, $s3           
bne $t3, $0, label  
