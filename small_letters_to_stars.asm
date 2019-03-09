.data 
wel:	.ascii	"enter string:\n"
str:	.space	100
.text
main:
         li $v0, 4
         la $a0, wel
         syscall
         
	 li $v0, 8
	 la $a0, str
	 li $a1, 100
	 syscall
	la	$t0,str
	li	$t1,'*'
loop:
	lb	$t2,($t0)
	beqz	$t2,end
	bgt	$t2,'z',next
	blt	$t2,'a',next
	move	$t2,$t1
	sb	$t2,($t0)
next:
	addi	$t0,$t0,1
	j	loop
end:
	li	$v0,4
	la	$a0,str
	syscall
	li	$v0,10
	syscall