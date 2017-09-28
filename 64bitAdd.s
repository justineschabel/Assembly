#This program adds two 64 bit numbers and stores the upper 32 bits in edx and the lower 32 bits in eax
.global _start 

#There will be two variables, num1 and num2
.data 

num1:
	.long -1
	.long -2
num2:
	.long -3
	.long -4

.text

#if a one is supposed to be carried in the lower 32 bits, it needs to be accounted for in the upper half
if_carry:
	 addl $1, %edx
	 jmp after_carry

_start:
	#move 1 wordsize past the beginning of the variables to get the lower half
	movl num1 + 4, %eax	
	addl num2 + 4, %eax

	jc if_carry
	movl $0, %edx


after_carry:
	addl num1, %edx
	addl num2, %edx

done:
	movl %eax, %eax
