	.data 
welcome:	.ascii	"enter sentence:\n"
str:		.space	128
	.text
main:	
	li	$v0,4
	la	$a0,welcome
	syscall
	li	$v0,8
	la	$a0,str
	li	$a1,128
	syscall
	li 	$s0,0
	li	$s1,1
loop:
	lb 	$t0,str($s0)
	lb	$t1,str($s1)
	beq	$t0,'\n',end
	beq	$t1,'\n',end
	sb	$t0,str($s1)
	sb	$t1,str($s0)
	addi	$s0,$s0,2
	addi	$s1,$s1,2
	j	loop	
end:
	
	li	$v0,4
	la 	$a0,str
	syscall
	li 	$v0,10
	syscall
	