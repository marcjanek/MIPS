.data
		.eqv	BUFFER_SIZE 	210021 #(10000*3+3)*7=210021
		.eqv	INPUT_BUFFER_SIZE	128
		.eqv	INIT_COLOR	255
filtred_lines:	.word	1
buf:		.space 	BUFFER_SIZE		
outBuf:		.space	BUFFER_SIZE
input_txt:	.asciiz	"input:	"
output_txt:	.asciiz	"output: "
mask_txt:	.asciiz	"mask: "
input:		.space	INPUT_BUFFER_SIZE
output:		.space	INPUT_BUFFER_SIZE
mask:		.space	INPUT_BUFFER_SIZE
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
#$t8=window
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
#$a3=padding

#$fp=input descriptor 
#$ra=output descriptor	
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
	move	$fp,	$v0	
	
	li	$v0,	14			
	move	$a0,	$fp
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
	li	$a1,	9
	li 	$a2,	0
	syscall
	bltz	$v0,	exit			
	move	$ra,	$v0

	li	$v0,	15			#load headers to out	
	move	$a0,	$ra
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
	mul	$v1,	$t2,	3
	add	$v1,	$v1,	$a3		#real size of line
	sw	$zero,	filtred_lines	
	
	li	$t0,	BUFFER_SIZE			#max lines in buf
	div 	$t4,	$t0,	$v1
	bgt	$t8,	$t4,	error
init_buf:
	li	$v0,	14	
	move	$a0,	$fp			#load lines to buf
	la	$a1,	buf
	ble	$t4,	$t3,	smaller_height
	move	$t4,	$t3
smaller_height:
	mul	$a2,	$v1	$t4
	syscall
	bne	$v0,	$a2,	error
init_RGB:					
	li	$t5,	INIT_COLOR	
	li	$t6,	INIT_COLOR	
	li	$t7,	INIT_COLOR
min_Y:
	sub	$s3,	$s1,	$t9
	bgez	$s3,	min_X
	li	$s3,	0
min_X:
	sub	$s2,	$s0,	$t9
	bgez	$s2,	max_Y
	li	$s2,	0
max_Y:
	add	$s5,	$s1,	$t9
	blt	$s5,	$t3,	max_X
	subi	$s5	$t3,	1
max_X:
	add	$s4,	$s0,	$t9
	blt	$s4,	$t2,	init_Y
	subi	$s4	$t2,	1
init_Y:
	move	$s7,	$s3
init_X:
	move	$s6,	$s2			#calculate pixel in buf
	div	$s7,	$t4
	mfhi	$t1
	mul	$t1,	$t1,	$v1
	mul	$t0,	$s6,	3
	addu	$t1,	$t1,	$t0
B:						#check colors
	lbu	$t0,	buf($t1)
	bge	$t0,	$t5,	G
	move	$t5,	$t0
G:
	addiu	$t1, 	$t1,	1
	lbu	$t0,	buf($t1)
	bge	$t0,	$t6,	R
	move	$t6,	$t0
R:
	addiu	$t1, 	$t1,	1
	lbu	$t0,	buf($t1)
	bge	$t0,	$t7,	check_next_pixel	
	move	$t7,	$t0
check_next_pixel:
	addiu	$t1,	$t1,	1		#pointer++
	addiu	$s6,	$s6,	1		#x++
	ble	$s6,	$s4,	B		#x<=max_x
	addiu	$s7,	$s7,	1		#y++
	ble	$s7,	$s5,	init_X		#y<=y_max
save_pixel:
	lw	$t0,	filtred_lines		#calculate place for colors in out buf
	mul	$s7,	$t0,	$v1		
	mul	$t0,	$s0,	3
	add	$s7,	$t0,	$s7
	sb	$t5,	outBuf($s7)		#store pixel
	addi	$s7, 	$s7,	1
	sb	$t6,	outBuf($s7)
	addi	$s7, 	$s7,	1
	sb	$t7,	outBuf($s7)

	addi	$s0,	$s0,	1		#global_x++
	blt	$s0,	$t2,	init_RGB	#global_x<width	
	
	move 	$s6,	$a3			#padding
add_padding:
	beqz	$s6,	end_add_padding					
	lb	$t0,	buf($t1)
	sb	$t0,	outBuf($s7)
	subi	$s6,	$s6,	1
	addiu	$t1, 	$t1,	1	
	j	add_padding	
end_add_padding:	
	lw	$t0,	filtred_lines
	addi	$t0	$t0,	1
	sw	$t0,	filtred_lines
	
	li	$s0,	0			#global_x=0
	addi	$s1,	$s1,	1		#global_y++
	bge	$s1,	$t3,	save		#end of file
	
	add	$t0,	$t9,	$t0
	blt	$s1,	$t4,	not_first_buf
	add	$t0,	$t9,	$t0
not_first_buf:
	blt	$t0,	$t4,	init_RGB	#end of buf									
save:
	li	$v0,	15
	move	$a0,	$ra
	la	$a1,	outBuf
	lw	$t0,	filtred_lines
	mul 	$a2,	$v1,	$t0
	syscall
	bltz	$v0,	error
	bge	$s1,	$t3,	exit		#end of file
	sw	$zero,	filtred_lines		#reset filtred lines

	li	$v0,	14
	move 	$a0,	$fp			#load new lines
min_mask:	
	sub	$s2,	$s1,	$t9	
	div	$s2,	$t4
	mfhi	$s2	
max_mask:
	add	$s3,	$s1,	$t9
	div	$s3,	$t4
	mfhi	$s3
	
	add	$t1,	$s1,	$t9
	sub	$t1,	$t3,	$t1		#total lines to put in buf
	
	ble	$s2,	$s3,	two_sys1
one_sys:
	mul	$t0,	$v1,	$s3
	la	$a1,	buf($t0)
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
	move	$a0,	$ra
	syscall
close_in:
	li	$v0,	16
	move	$a0,	$fp
	syscall
	li	$v0,	10
	syscall
