/* 

	Implements matrix multiplication in assembly.

*/


/*
#include <stdio.h>
#include <stdlib.h>

int** matMult(int **a, int num_rows_a, int num_cols_a, int** b, int num_rows_b, int num_cols_b) {

	int row, col, i;
	int** mult = (int**)malloc(num_rows_a * sizeof(int*));
	  for(row = 0; row < num_rows_a; ++row) {
	  	mult[row] = (int*)malloc(num_cols_b * sizeof(int));
        for(col = 0; col < num_cols_b; ++col) {
        	mult[row][col] = 0;
            for(i = 0; i < num_cols_a; ++i)
 			{
                mult[row][col] += a[row][i] * b[i][col];
            }
        }
    }

    return mult;

}
*/

.global matMult
.equ ws, 4

.text


matMult:
prologue: 
	push %ebp
	movl %esp, %ebp
	subl $4*ws, %esp #subtract space for locals 
	#save registers
	push %ebx #rows
	push %esi #i
	push %edi #a

	/*stack
	num_cols_b
	num_rows_b
	**b
	num_cols
	num_rows
	**a
	ret address

	ebp 
	row
	col
	i
	mult
	*/

	.equ num_cols_b, (7*ws)
	.equ num_rows_b, (6*ws)
	.equ b, (5*ws)
	.equ num_cols_a, (4*ws)
	.equ num_rows_a, (3*ws)
	.equ a, (2*ws)
	#ret address
	#prologue
	.equ row, (-1*ws)
	.equ col, (-2*ws)
	.equ i, (-3*ws)
	.equ mult, (-4*ws)

#int** mult = (int**)malloc(num_rows_a * sizeof(int*));
	movl num_rows_a(%ebp), %eax	 # eax = num_rows_a
	shll $2, %eax # num_rows_a * sizeof(int*)
	push %eax

	movl %edx,%ebx # save edx before malloc called

	call malloc

	movl %ebx,%edx # restore edx

	addl $1*ws, %esp # remove arguments from the stack
	movl %eax, mult(%ebp) # mult = address of malloc call

#edx is row
#for(row = 0; row < num_rows_a; ++row) 
	movl $0, %edx # edx = 0
	outer_for:
	cmpl num_rows_a(%ebp), %edx
	jge end_outer_for
		
#mult[row] = (int*)malloc(num_cols_b * sizeof(int))
	movl %edx, row(%ebp) # rows = edx
	movl num_cols_b(%ebp), %eax # eax = num_cols_b
	shll $2, %eax # eax = num_cols_b * sizeof(int)
	push %eax # put eax on the stack

	call malloc
	addl $1*ws, %esp # clear the arguments
	movl row(%ebp), %edx # edx = row
	movl mult(%ebp), %ecx # ecx = mult
	movl %eax, (%ecx, %edx, ws) # ecx = mult[row]

#ebx is col
#for(col = 0; col < num_cols_b; ++col) 
	movl $0, %ebx
	middle_for:
		cmpl num_cols_b(%ebp), %ebx
		jge end_middle_for
		movl mult(%ebp), %ecx # ecx = mult
		# mult[row][col] = 0; #ecx will be a temporary reg to hold 0
		# mult[row][col] = *(*mult + row) + col)
		movl (%ecx, %edx, ws), %ecx # ecx = mult[row]
		movl $0, (%ecx, %ebx, ws) # ecx = mult[row][col] 
		#movl $0, %ecx # ecx = mult[row][col] = 0
		
		#esi is i
		#for(i = 0; i < num_cols_a; ++i)
		movl $0, %esi
		inner_for:
			cmpl num_cols_a(%ebp), %esi
			jge end_inner_for
			
			#mult[row][col] = mult[row][col] + a[row][i] * b[i][col];
			#b[i][col]== *(*(b+i)+col)
			movl b(%ebp), %eax #eax = b
			movl (%eax, %esi, ws), %eax # eax = b[i]
			movl (%eax, %ebx, ws), %eax # eax = b[i][col]
			
			#a[row][i] = *(*(a+row)+i)
			movl a(%ebp), %edi # edi = a
			movl (%edi, %edx, ws), %edi # edi = a[row]
			movl (%edi, %esi, ws), %edi # edi = a[row][i]
	
			movl %edx, %ecx # save edx
			mull %edi # eax * edi
			movl %ecx,%edx # restore ecx

			#addl %edi, %ecx # ecx = a[row][i] * b[i][col]


			movl mult(%ebp), %ecx # ecx = mult
			movl (%ecx,%edx,ws), %ecx # ecx = mult[row] 
			addl %eax, (%ecx, %ebx, ws) # mult[row][col] = %ecx
			
			incl %esi # i++
			jmp inner_for
			
		end_inner_for:
			incl %ebx # col++
			jmp middle_for

	end_middle_for:

		incl %edx # row++	
		jmp outer_for

end_outer_for:
	
movl mult(%ebp), %eax  # return mult

epilogue:
	pop %edi
	pop %esi
	pop %ebx
	movl %ebp, %esp
	pop %ebp
	ret






