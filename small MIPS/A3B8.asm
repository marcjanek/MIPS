	.data 
wel:	.ascii	"enter sentence: "
str:	.space	128
out:	.space	128
	.text	
main:
	li	$v0,4
	la	$a0,wel
	syscall
	li	$v0,8
	la	$a0,str
	li	$a1,128
	syscall
	la	$t4,out
	la	$t5,str
	la	$t6,str
	addi	$t6,$t6,1
loop:	
	lb	$t0,($t5)
	lb	$t1,($t6)
	beqz	$t1,end
loop_1:
	beq	$t1,'0',next
	sb	$t0,($t4)
	subi	$t1,$t1,1
	addi	$t4,$t4,1	
	j	loop_1
next:
	addi	$t5,$t5,2
	addi	$t6,$t6,2
	j	loop
end:
	li	$v0,4
	la	$a0,out
	syscall
	li	$v0,10
	syscall