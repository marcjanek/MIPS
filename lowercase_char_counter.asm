.data
str:	.space	128
wel:	.asciiz	"enter sentence: "
.text
main: 	li	$v0,4
	la	$a0,wel
	syscall
	li	$v0,8
	la	$a0,str
	li	$a1,128
	syscall
	li	$t0,'a'
loop:	beq	$t0,'{',end
	la	$t1,str
	li	$t3,0
loop_1:	lb	$t2,($t1)
	beq	$t2,'\n',reset
	bne	$t2,$t0,next
	addi	$t3,$t3,1	
next:	addi	$t1,$t1,1
	j	loop_1	
reset:	beq	$t3,0,no_out
	li	$v0,11
	la	$a0,($t0)
	syscall
	li	$v0,1
	la	$a0,($t3)
	syscall
no_out:	addi	$t0,$t0,1
	j	loop	
end:	li	$v0,10
	syscall