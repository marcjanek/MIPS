.data
str:	.space	128
wel:	.asciiz	"enter sentence: "
.text
main:
	li $v0,4
	la $a0,wel
	syscall
	li $v0,8
	la $a0,str
	li $a1,128
	syscall
	la $t6,str
len:
	lb $t0,($t6)
	beq $t0,'\n',len_break
	addi $t6,$t6,1
	j len
len_break:
	la $t5,str
front_loop:
	bge $t5,$t6,end
	lb $t0,($t5)
	bgt $t0,'9',next_front_loop
	blt $t0,'0',next_front_loop
	j end_loop	
next_front_loop:
	addi $t5,$t5,1
	j front_loop
end_loop:
	bge $t5,$t6,end
	lb $t1,($t6)
	bgt $t1,'9',next_end_loop
	blt $t1,'0',next_end_loop
	j swap	
next_end_loop:
	subi $t6,$t6,1
	j end_loop
swap:
	sb $t0,($t6)
	sb $t1,($t5)
	addi $t5,$t5,1
	subi $t6,$t6,1
	j front_loop	
end:
	li	$v0,4
	la	$a0,str
	syscall
	li	$v0,10
	syscall