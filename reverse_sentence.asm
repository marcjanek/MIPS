.data
wel_txt:	.ascii "Hi,enter sentence\n"
str:		.space	1024
	.text
	main:
	li	$v0,4
	la	$a0,wel_txt
	syscall
	
	la 	$a0,str
	li	$a1,100
	li	$v0,8
	syscall
	
	
	li	$s0,0	#back	
	li	$s1,0	#front
	lb	$t0,str($s0)
	beqz	$t0,end
length:
	addi	$s0,$s0,1
	lb	$t0,str($s0)
	beqz	$t0,sub_newline
	j	length
sub_newline:
	subi	$s0,$s0,2
swap:
	lb	$t1,str($s1)
	lb	$t2,str($s0)
	sb	$t1,str($s0)
	sb	$t2,str($s1)
	
	addi	$s1,$s1,1
	subi	$s0,$s0,1
	bgt 	$s1,$s0,end
	j	swap

end:
	li	$v0,4
	la	$a0,str
	syscall
	li	$v0,10
	syscall
		