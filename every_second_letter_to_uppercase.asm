	.data 
wel:	.ascii	"enter sentence: "
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
	la	$t6,str
loop:
	lb	$t0,($t6)
	beq	$t0,'\n'end
	beqz	$t0,end
	bgt	$t0,'z',next
	blt	$t0,'a',next
	subi	$t0,$t0,32
	sb	$t0,($t6)
next:	
	addi	$t6,$t6,2
	j	loop
end:
	li	$v0,4
	la	$a0,str
	syscall
	li	$v0,10
	syscall