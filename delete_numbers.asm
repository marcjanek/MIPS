	.data
wel:	.ascii	"enter sentence:\n"
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
	la	$t6,str
	li	$s0,0
loop:
	lb	$t0,($t6)
	beqz	$t0,end
	bgt	$t0,'9',next
	blt	$t0,'0',next
	j	loop_1
next:	
	sb	$t0,out($s0)
	addi	$s0,$s0,1
loop_1:
	addi	$t6,$t6,1
	j	loop
end:
	li	$t0,'\n'
	addi	$s0,$s0,1
	sb	$t0,out($s0)
	li	$v0,4
	la	$a0,out
	syscall
	li	$v0,10
	syscall
	