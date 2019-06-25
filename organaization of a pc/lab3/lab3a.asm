.data
Give_Roman_Number : .asciiz "Please give a valid roman number!"
Wrong_Number : .asciiz "The number you gave was invalid.Please give us a valid roman number!"
Result : .asciiz "The roman number you gave us is the following in decimal :"
Input: .space 100

.text
.globl main

main:
li $v0, 4
la $a0, Give_Roman_Number
syscall

loop:
li $v0, 8
li $a1, 21
la $a0, Input
syscall

lb $t0,($a0)
beq $t0,10,not_valid

la $t1,($a0)#sozw ton pointer stin arxi tou string gia na mporw na ksekinisw apo tin arxi meta tin klisi tis check_roman
add $sp,$sp,-4
sw $t1,($sp)

jal check_roman

lw $t1,($sp)
add $sp,$sp,4

beqz $v0,not_valid
j valid

not_valid:
li $v0, 4
la $a0, Wrong_Number
syscall
j loop

valid:
la $a0,($t1)

move $v0,$zero
jal roman_to_decimal
move $t0,$v0

li $v0, 4
la $a0, Result
syscall

move $a0,$t0
li $v0,1
syscall

#psofos
li $v0, 10
syscall

check_roman:
lb $t0,($a0)
beq $t0,10,newline

# switch case gia ta grammata
beq $t0,'M',is_roman
beq $t0,'D',is_roman
beq $t0,'C',is_roman
beq $t0,'L',is_roman
beq $t0,'X',is_roman
beq $t0,'V',is_roman
beq $t0,'I',is_roman

not_roman:
move $v0,$zero
jr $ra

is_roman:
add $sp,$sp,-4
sw $ra,($sp)
add $a0,$a0,1
jal check_roman

lw $ra,($sp)
add $sp,$sp,4

bnez $v0,continue # an einai egkiros o epomenos kane jump sto continue, alliws girnaei 0
move $v0,$zero
jr $ra

continue:
add $v0,$zero,1
jr $ra

newline:
add $v0,$zero,1
jr $ra

roman_to_decimal:
add $sp,$sp,-4
sw $ra,($sp)
lb $t0,($a0)
add $a0,$a0,1
lb $t4,($a0)

# switch case gia ta grammata
beq $t0,'M',xilia
beq $t0,'D',pentakosia
beq $t0,'C',ekato
beq $t0,'L',peninta
beq $t0,'X',deka
beq $t0,'V',pente
beq $t0,'I',ena

xilia:
add $t0,$zero,1000
j second_num
pentakosia:
add $t0,$zero,500
j second_num
ekato:
add $t0,$zero,100
j second_num
peninta:
add $t0,$zero,50
j second_num
deka:
add $t0,$zero,10
j second_num
pente:
add $t0,$zero,5
j second_num
ena:
add $t0,$zero,1

second_num:
beq $t4,'M',xilia2
beq $t4,'D',pentakosia2
beq $t4,'C',ekato2
beq $t4,'L',peninta2
beq $t4,'X',deka2
beq $t4,'V',pente2
beq $t4,'I',ena2
beq $t4,'\n',newline_roman

xilia2:
add $t4,$zero,1000
j praksi
pentakosia2:
add $t4,$zero,500
j praksi
ekato2:
add $t4,$zero,100
j praksi
peninta2:
add $t4,$zero,50
j praksi
deka2:
add $t4,$zero,10
j praksi
pente2:
add $t4,$zero,5
j praksi
ena2:
add $t4,$zero,1
j praksi

newline_roman:
move $t4,$zero

praksi:
bge $t0,$t4,prosthesi #an to epomeno stoixeio einai mikrotero prepei na kanw prosthesi
afairesi:
sub $v0,$v0,$t0
j return
prosthesi:
add $v0,$v0,$t0



return:#an einai to epomeno \n simainei oti exw ftasei sto telos tou arithmou mou, alliws sinexizw tin klisi me to epomeno stoixeio
beqz $t4,exit
jal roman_to_decimal
exit:
lw $ra,($sp)
add $sp,$sp,4
jr $ra
