.data
wel:	.ascii	"enter sentence: "
str:	.space	128
out:	.space	128
.text
	li	$v0,4
	la	$a0,wel
	syscall
	li	$v0,8
	la	$a0,str
	li	$a1,128
	syscall
	la	$t6,str
	la	$t5,out
loop:
	lb	$t0,($t6)
	beq	$t0,'\n',end
	bgt	$t0,'9',not_number
	blt	$t0,'0',not_number
	j next
not_number:
	sb	$t0,($t5)
	addi	$t5,$t5,1	
next:
	addi	$t6,$t6,1
	j	loop	
end:
	li	$v0,4
	la	$a0,out
	syscall
	li	$v0,10
	syscall