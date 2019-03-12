	.data
wel:	.asciiz	"enter sentence: "
str:	.space	128
	.text
main:	
	li	$v0,4
	la	$a0,wel
	syscall
	li	$v0,8
	la	$a0,str
	li	$a1,128
	syscall
	li	$t0,'a'
	add	$t0,$t0,$t0
	addi	$t0,$t0,25
	la	$t6,str
loop:	
	lb	$t1,($t6)
	beq	$t1,'\n',end
	sub	$t1,$t0,$t1
	sb	$t1,($t6)
	addi	$t6,$t6,1
	j	loop
end:
	li	$v0,4
	la	$a0,str
	syscall
	li	$v0,10
	syscall
	