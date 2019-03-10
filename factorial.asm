	.data 
wel:	.ascii	"enter number: "
	.text	
main:
	li	$v0,4
	la	$a0,wel
	syscall
	li	$v0,5
	syscall
	move	$t6,$v0
	li	$t0,1
	beq	$t6,0,end
loop:
	beq	$t6,1,end
	mulu	$t0,$t0,$t6
	subi	$t6,$t6,1
	j	loop
end:
	li	$v0,1
	la	$a0,($t0)
	syscall
	li	$v0,10
	syscall