	.data
size: 	.space 4
width:	.space 4
height:	.space 4
mask:   .space 4
square: .space 4
padding:.space 4
tab:	.space 1024 
buf:	.space 17179869184
out: 	.space 3

input:.asciiz "kobieta.bmp"
output:.asciiz "out.bmp"

#input:	.space 64
#output: .space 64

helloT:	.asciiz "Welcome to minimal filter for BMP pictures\n"
inputT:	.asciiz "\nEnter name of input BMP file: "
outputT:.asciiz "\nEnter name of output BMP file: "
maskT:	.asciiz	"\nEnter size of mask: "
errorT:	.asciiz "Something went wrong, try later or enter data well -_-\n" 
#$t0==local var
#$t1==local var
#$t2==min R
#$t3==min G
#$t4==min B
#$t5==output descriptor
#$t6==input descriptor

#$s0==glob x
#$s1==glob y
#$s2==min x
#$s3==min y
#$s4==max x
#$s5==max y
#$s6==cur x
#$s7==cur y



	.text
main:
	li $v0,4
	la $a0,helloT
	syscall
#	
#	li $v0,4		#enter input file name
#	la $a0,inputT	
#	syscall
#	li $v0,8
#	la $a0,input
#	li $a1,64
#	syscall
#	
#	li $v0,4		#enter output file name
##	la $a0,outputT	
#	syscall
#	li $v0,8
#	la $a0,output
#	li $a1,64
#	syscall
	
	#li $v0,4		#enter mask size
	#la $a0,maskT	
	#syscall
	#li $v0,5
	#syscall
	#sw $v0,mask
	li $t0,5
	sw $t0,mask
	
	la $t6,input			#delete \n in input
loop_correct_input:
	lb $t0,($t6)
	beq $t0,'\n',correct_input
	addiu $t6,$t6,1
	j loop_correct_input 	
correct_input:
	sb $0,($t6)
	
	la $t6,output			#delete \n in output
loop_correct_output:
	lb $t0,($t6)
	beq $t0,'\n',correct_output
	addiu $t6,$t6,1
	j loop_correct_output 	
correct_output:
	sb $0,($t6)
	
	#open input file
	li $v0,13
	la $a0,input
	li $a1,0
	syscall
	
	#open error check
	bltz $v0,error_exit#TODO special error
	move $t6,$v0
	#read from input header
	li $v0,14
	move $a0,$t6
	la $a1,tab+2
	li $a2,54#14+40
	syscall

	
	#check HEADERS
	bne $v0,54,close_input
	
	lh $t0,tab+2
	bne $t0,0x4D42,close_input#42==B,4D==M
	
	lw $t0,tab+8
	bnez $t0,close_input#0 at 6 and 0 at 8
	
	#lh $t0,tab+8
	#bnez $t0,close_input#0 at 6 and 0 at 8
	
	lh $t0,tab+16
	bne $t0,40,close_input#BITMAPINFOHEADER length == 40
	
	#read to pixels 
	li $v0,14
	la $a0,input
	la $a1,tab+2
	la $a2,tab+12
	syscall
	
	lw $t0,tab+20#width
	sw $t0,width
	lw $t0,tab+24#height
	sw $t0,height
	
	#create output
	li $v0,13
	la $a0,output
	li $a1,9
	syscall
	#t5==file output descriptor
	move $t5,$v0
	bltz $t5,close_output#error when open out file
	
	#write headers to new file
	li $v0,15
	move $a0,$t5
	la $a1,tab+2
	la $a2,54
	syscall
	
	bne $v0,$a2,close_output#error when write out file
	
	#padding
	lw $t3,width
	mul $t0,$t3,3
	li  $t1,4
	div $t0,$t1
	mfhi $t0
	beqz $t0,calculate_square
	sub $t0,$t1,$t0#4-padding
calculate_square:
	sw $t0,padding
	
	lw $t0,mask
	blez $t0,error_exit
	subi $t0,$t0,1
	li $t1,2
	div $t0,$t1
	sw $t0,square
	
	
#$t0==local var
#$t1==local var
#$t2==min R
#$t3==min G
#$t4==min B
#$t5==output descriptor
#$t6==input descriptor

#$s0==glob x
#$s1==glob y
#$s2==min x
#$s3==min y
#$s4==max x
#$s5==max y
#$s6==cur x
#$s7==cur y
	li $s1,0
global_Y_loop:
	lw $t0,height
	beq $s1,$t0,end_global_Y_loop
	
	li $s0,0
global_X_loop:
	lw $t0,width
	beq $s1,$t0,end_global_X_loop
	
	lw $t0,square
min_Y:
	sub $s3,$s1,$t0
	bgez $s3,min_X
	li $s3,0
min_X:
	sub $s2,$s0,$t0
	bgez $s2,max_Y
	li $s2,0
max_Y:
	add $s5,$s1,$t0
	addi $s5,$s5,1
	lw $t1,height
	blt $s5,$t1,max_X
	move $s5,$t1
max_X:
	add $s4,$s0,$t0
	add $s4,$s4,1
	lw $t1,width
	blt $s4,$s1,RGB
	move $s4,$s1
RGB:
	li $t2,255
	li $t3,255
	li $t4,255

	move $s7,$s3
local_Y_loop:
	beq $s7,$s5,end_local_Y_loop
	
	move $s6,$s2
local_X_loop:
	beq $s6,$s4,end_local_X_loop
		
	#TODO find load and calc min 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	addi $s6,$s6,1
	j local_X_loop
end_local_X_loop:
	addi $s7,$s7,1
	j local_Y_loop
end_local_Y_loop:

	sw $s4,out+2
	sw $s3,out+1
	sw $s2,out
		
	li	$v0,15
	move	$a0,$s1
	la	$a1,out
	li	$a2,3
	syscall
	bltz	$v0,close_output	
	
	addi $s0,$s0,1
	j global_X_loop
	
end_global_X_loop:
			
	addi $s1,$s1,1
	j global_Y_loop
end_global_Y_loop:
		
	j close_output
	
	
error_exit:
	li $v0,4
	la $a0,errorT
	syscall
close_output:
	#TODO
close_input:
	#TODO
exit:
	li $v0,10
	syscall
	
	
