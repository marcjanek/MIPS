# Daniel J. Ellard -- 02/21/94
# add2.asm-- A program that computes and prints the sum
# of two numbers specified at runtime by the user.
# Registers used:
# $t0 - used to hold the first number.
# $t1 - used to hold the second number.
# $t2 - used to hold the sum of the $t1 and $t2.
#2.4. USING SYSCALL: ADD2.ASM 25
# $v0 - syscall parameter.
main:
## Get first number from user, put into $t0.
## Get second number from user, put into $t1.
add $t2, $t0, $t1 # compute the sum.
## Print out $t2.
li $v0, 10 # syscall code 10 is for exit.
syscall # make the syscall.
# end of add2.asm.