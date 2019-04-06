.data
str: .space 128
wel: .asciiz "enter sentence:"
.text
	li	$v0,4
	la	$a0,wel
	syscall
	li	$v0,8
	la	$a0,str
	li	$a1,128
	syscall
	la 	$t5,str
	la	$t6,str
len:
	lb	$t1,($t6)
	beq	$t1,'\n',front
	addi	$t6,$t6,1
	j	len	
front:
	bge 	$t5,$t6,exit
	lb	$t0,($t5)
	bgt	$t0,'9',next_front
	blt	$t0,'0',next_front
	j 	end
next_front:
	addi	$t5,$t5,1
	j	front
end:
	bge	$t5,$t6,exit
	lb	$t1,($t6)
	bgt	$t1,'9',next_end
	blt	$t1,'0',next_end
	j	swap
next_end:
	subi	$t6,$t6,1
	j	end
swap:
	sb	$t0,($t6)
	sb	$t1,($t5)
	addi	$t5,$t5,1
	subi	$t6,$t6,1
	j 	front	
exit:
	li	$v0,4
	la	$a0,str
	syscall
	li	$v0,10
	syscall