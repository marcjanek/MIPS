.data
		.eqv	BUFFER_SIZE 	210021 #(10000*3+3)*7=210021
		.eqv	INPUT_BUFFER_SIZE	128
		.eqv	INIT_COLOR	255
buf:		.space 	BUFFER_SIZE		
outBuf:		.space	BUFFER_SIZE
input_txt:	.asciiz	"input:	"
output_txt:	.asciiz	"output: "
mask_txt:	.asciiz	"mask: "
input:		.space	INPUT_BUFFER_SIZE
output:		.space	INPUT_BUFFER_SIZE
mask:		.space	INPUT_BUFFER_SIZE
input_des:	.word 	1
output_des:	.word	1
padding:	.word 	1
error_txt:	.asciiz "error :/\n"
success_txt:	.asciiz "filtred :D\n"
.text
#main meaning				local	meaning

#$t0=var
#$t1=pointer				/var//lines left to read
#$t2=width				
#$t3=height				
#$t4=lines in buf			
#$t5=B			
#$t6=G						
#$t7=R
#$t8=window				/later filtred lines in current cycle
#$t9=(window-1)/2

#$s0=global x
#$s1=global y
#$s2=min x				/min left byte in buf
#$s3=min y				/first free byte mod lines in buf
#$s4=max x				
#$s5=max y	
#$s6=cur x
#$s7=cur y

#$v1=width*3+padding

	li 	$fp,	0
	li 	$v0,	4
	la	$a0,	input_txt
	syscall
	li	$v0,	8
	la	$a0	input
	li	$a1,	INPUT_BUFFER_SIZE
	syscall
	la 	$t6,	input			#delete \n in input
loop_correct_input:
	lb 	$t0,	($t6)
	beq 	$t0,	'\n',	correct_input
	addiu 	$t6,	$t6,	1
	j 	loop_correct_input 	
correct_input:
	sb 	$0,	($t6)
	
	li	$v0,	4
	la	$a0,	output_txt
	syscall
	li	$v0,	8
	la	$a0,	output
	syscall
	la 	$t6,	output			#delete \n in output
loop_correct_output:
	lb	$t0,	($t6)
	beq 	$t0,	'\n',	correct_output
	addiu 	$t6,	$t6,	1
	j 	loop_correct_output 	
correct_output:
	sb $0,	($t6)
	
	li	$v0,	4
	la	$a0,	mask_txt
	syscall
	li	$v0,	8
	la	$a0,	mask
	syscall
	la	$t6,	mask
atoi:
	lb	$t0,	($t6)
	beq	$t0,	'\n',	end_atoi
	blt	$t0,	'0',	error
	bgt	$t0,	'9',	error
	mul	$t9,	$t9,	10
	sub	$t0,	$t0,	'0'
	add	$t9,	$t9,	$t0
	addi	$t6,	$t6,	1
	j	atoi
end_atoi:
	mul	$t8,	$t9,	2
	addi	$t8,	$t8,	1
	
	li	$v0,	13			
	la	$a0,	input
	li	$a1,	0	
	syscall
	bltz	$v0,	error			
	sw	$v0,	input_des	
	
	li	$v0,	14			
	lw	$a0,	input_des
	la	$a1,	buf+2			
	li	$a2,	54
	syscall
	bne	$v0,	$a2,	close_in	

	lh	$t0,	buf+2
	bne	$t0,	0x4D42,	close_in	#42==B,4D==M
	
	lw	$t0,	buf+8
	bnez	$t0,	exit			# 00

	lw	$t2,	buf+20			# width
	bgt	$t2,	10000,	close_in
    	ble 	$t2,    $t8,    close_in
	lw	$t3,	buf+24			# height

	lw	$t0,	buf+12			
	li	$v0,	14			
	la	$a1,	buf+56
	sub	$a2,	$t0,	54
	syscall

	li	$v0,	13			#open out	
	la	$a0,	output
	li	$a1,	1
	li 	$a2,	0
	syscall
	bltz	$v0,	exit	
	sw	$v0,	output_des		

	li	$v0,	15			#load headers to out	
	lw	$a0,	output_des
	la	$a1,	buf+2
	lw	$a2,	buf+12
	syscall
	bne	$v0,	$a2,	error	

	li	$t1,	4			#padding
	mul	$a3,	$t2,	3		
	div	$a3,	$t1
	mfhi	$a3		
	beqz	$a3,	check_height 
	sub	$a3,	$t1,	$a3
check_height:
	sw	$a3,	padding
	mul	$v1,	$t2,	3
	add	$v1,	$v1,	$a3			
	
	li	$t0,	BUFFER_SIZE			
	div 	$t4,	$t0,	$v1
	bgt	$t8,	$t4,	error
	li 	$t8,	0			
init_buf:
	li	$v0,	14	
	lw	$a0,	input_des			
	la	$a1,	buf
	ble	$t4,	$t3,	smaller_height
	move	$t4,	$t3
smaller_height:
	mul	$a2,	$v1	$t4
	syscall
	bne	$v0,	$a2,	error
	mul	$sp,	$v1,	$t4
	mul	$gp,	$t9,	3
	mul	$t0,	$t9,	$v1
init_RGB:					
	li	$t5,	INIT_COLOR#255	
	li	$t6,	INIT_COLOR	
	li	$t7,	INIT_COLOR
min_Y:
	sub	$s3,	$s1,	$t9
	bltz	$s3,	save_pixel
min_X:
	sub	$s2,	$s0,	$t9
	bltz	$s2,	save_pixel
max_Y:
	add	$s5,	$s1,	$t9
	bge	$s5,	$t3,	save_pixel
max_X:
	add	$s4,	$s0,	$t9
	bge	$s4,	$t2,	save_pixel
init_Y:
	move	$s7,	$s3
	sub 	$a3,	$fp,	$t0
	sub	$a3,	$a3,	$gp
	div	$a3,	$sp
	mfhi	$t1
init_X:
	move	$s6,	$s2
						
B:						
	lbu	$a0,	buf($t1)
	bge	$a0,	$t5,	G
	move	$t5,	$a0
G:
	addiu	$t1, 	$t1,	1
	lbu	$a0,	buf($t1)
	bge	$a0,	$t6,	R
	move	$t6,	$a0
R:
	addiu	$t1, 	$t1,	1
	lbu	$a0,	buf($t1)
	bge	$a0,	$t7,	check_next_pixel	
	move	$t7,	$a0
check_next_pixel:
	addiu	$t1,	$t1,	1		
	addiu	$s6,	$s6,	1		
	ble	$s6,	$s4,	B		
	add	$a3,	$a3,	$v1
	div	$a3,	$sp
	mfhi	$t1
	addiu	$s7,	$s7,	1		
	ble	$s7,	$s5,	init_X		
save_pixel:
			
	
	sb	$t5,	outBuf($ra)		#store pixel
	addi	$ra, 	$ra,	1
	sb	$t6,	outBuf($ra)
	addi	$ra, 	$ra,	1
	sb	$t7,	outBuf($ra)
	addi	$ra,	$ra,	1

	addi	$s0,	$s0,	1		
	addi	$fp,	$fp,	3
	blt	$s0,	$t2,	init_RGB		
	
	lw 	$s6,	padding			
	add	$fp,	$fp,	$s6
add_padding:
	beqz	$s6,	end_add_padding					
	lb	$a0,	buf($t1)
	sb	$a0,	outBuf($ra)
	subi	$s6,	$s6,	1
	addiu	$ra, 	$ra,	1	
	j	add_padding	
end_add_padding:	
	addi	$t8	$t8,	1		
	
	li	$s0,	0			
	addi	$s1,	$s1,	1		
	bge	$s1,	$t3,	save		
	
	add	$a0,	$t9,	$t8
	blt	$s1,	$t4,	not_first_buf
	add	$a0,	$t9,	$a0
not_first_buf:
	blt	$a0,	$t4,	init_RGB										
save:
	li	$v0,	15
	lw	$a0,	output_des
	la	$a1,	outBuf
	move 	$a2,	$ra
	syscall
	bltz	$v0,	error
	bge	$s1,	$t3,	exit		
	li	$t8,	0		
	li 	$ra,	0

	li	$v0,	14
	lw 	$a0,	input_des			
min_mask:	
	sub	$s2,	$s1,	$t9	
	div	$s2,	$t4
	mfhi	$s2	
max_mask:	
	add	$s3,	$s1,	$t9
	div	$s3,	$t4
	mfhi	$s3
	
	add	$t1,	$s1,	$t9
	sub	$t1,	$t3,	$t1		
	
	ble	$s2,	$s3,	two_sys1
one_sys:
	mul	$a1,	$v1,	$s3
	la	$a1,	buf($a1)
	sub	$a2,	$s2,	$s3
	bnez	$a2,	size_not_zero
	move	$a2,	$t4
size_not_zero:
	bge	$t1,	$a2,	not_end_lines
	move	$a2,	$t1
not_end_lines:
	mul	$a2,	$a2,	$v1
	syscall
	bne	$v0,	$a2,	error
	j	init_RGB
two_sys1:
	mul	$a1,	$s3,	$v1
	la	$a1,	buf($a1)
	sub	$a2,	$t4,	$s3
	bge	$t1,	$a2,	not_end_lines1
	move	$a2,	$t1
not_end_lines1:
	sub	$t1,	$t1,	$a2
	mul	$a2,	$v1,	$a2
	syscall
	bne	$v0,	$a2,	error
	beqz	$t1,	init_RGB
	li	$v0,	14
two_sys2:	
	la	$a1,	buf
	move	$a2,	$s2
	bge	$t1,	$a2,	not_end_line2
	move	$a2,	$t1
not_end_line2:
	mul	$a2,	$a2,	$v1
	syscall
	bne	$v0,	$a2,	error
	j	init_RGB
	
close_in:
	li 	$v0,	4
	la	$a0,	error_txt
	syscall
	j	close_in1
error:	
	li	$v0,	4
	la	$a0,	error_txt
	syscall
	j	close_out
exit:
	li 	$v0,	4
	la	$a0,	success_txt
	syscall
close_out:
	li	$v0,	16		
	lw	$a0,	output_des
	syscall
close_in1:
	li	$v0,	16
	lw	$a0,	input_des
	syscall
	li	$v0,	10
	syscall
