	.data 
wel:	.ascii	"enter	sentence\n"
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
	li	$s0,0
	la	$t6,str
loop:
	lb	$t0,($t6)
	beq	$t0,'\n',end
	li	$t1,'0'
loop_1:
	beq	$t1,$t0,next
	addi	$t1,$t1,1
	j	loop_1
next:
	add	$s0,$s0,$t1
	subi	$s0,$s0,'0'
	addi	$t6,$t6,1
	j	loop
end:
	li	$v0,1
	la	$a0,($s0)
	syscall
	li	$v0,10
	syscall