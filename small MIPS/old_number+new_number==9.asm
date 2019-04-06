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
	la	$t6,str
loop:
	lb	$t0,($t6)
	beqz	$t0,end
	bgt	$t0,'9',not_number
	blt	$t0,'0',not_number
	li	$t1,'0'
loop_1:
	add	$t2,$t1,$t0
	beq	$t2,105,save
	addi	$t1,$t1,1
	j	loop_1
save:
	sb	$t1,($t6)
not_number:
	addi	$t6,$t6,1
	j	loop
end:
	li	$v0,4
	la	$a0,str
	syscall
	li	$v0,10
	syscall