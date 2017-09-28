/* 

	This program generates all the possible combinations 
	of a set of items of a given size.

	Note: get_combs is the first function called

*/

.global get_combs
.equ ws, 4

.text

store_ar:
store_ar_prologue:
	push %ebp
	movl %esp, %ebp
	subl $1*ws, %esp #subtract space for locals
	# save registers 
	push %ebx
	push %edi
	push %esi

	/*  stack
	*count
	**mat
	len
	*ar
	ret address

	ebp
	i
	*/

	.equ count, (5*ws)
	.equ mat, (4*ws)
	.equ len, (3*ws)
	.equ ar, (2*ws)
	# ret addr
	.equ i, (-1*ws)

/* 
void store_ar(int* ar, int len, int** mat, int *count){
  //print the elements of an array of length len
  int i;
  for(i = 0; i < len; i++){
     mat[*count][i] = ar[i]; 
  }
  ++(*count);
}
*/

# ebx is i
# for(i = 0; i < len; i++)
	movl $0, %ebx
	loop0:
	cmpl len(%ebp), %ebx
	jge end_loop0

	# mat[*count][i] = ar[i]
	movl count(%ebp), %edx # edx will hold count
	movl (%edx), %edx # dereference count
	movl mat(%ebp),%ecx # ecx = mat
	movl (%ecx,%edx,ws), %ecx # eax = mat[count]
	# movl (%ecx,%ebx,ws), %ecx  # ecx = mat[*count][i]

	# ar[i]
	movl ar(%ebp), %eax # eax will hold ar
	movl (%eax,%ebx,ws), %edi # edi = ar[i]
	movl %edi, (%ecx,%ebx,ws) # ecx = mat[*count][i] = ar[i]
	
	incl %ebx # ebx++
	jmp loop0

	end_loop0:
	incl %edx # count++
	movl count(%ebp), %esi
	movl %edx, (%esi)

    done_loop:

store_ar_epilogue:
	pop %esi
	pop %edi
	pop %ebx
	movl %ebp, %esp
	pop %ebp
	ret

/*
void _combs(int* items, int len, int k, int* cur_comb, int max_k, int** mat, int *count){
  int i;
  
  if(k == 0){ //if k is 0 we have completed a combination
    store_ar(cur_comb, max_k, mat, count); //so display it
  }
  else if(len < k){ //not enough elements to complete the combination
    return;
  }
  else{
    for(i = 0; i < len; i++){ //for each element in the list
      cur_comb[max_k - k] = items[i];//add it to our current combination
      _combs(items + i + 1, len - i - 1,  k - 1, cur_comb, max_k, mat, count); //create a combination of the rest
    } //end of loop
  
  } //end of else

}//_combs
*/

# void _combs(int* items, int len, int k, int* cur_comb, int max_k, int** mat, int *count)
_combs:
_combs_prologue:
	push %ebp
	movl %esp, %ebp
	subl $1*ws, %esp # subtract space for locals
	# save registers 

	push %ebx
	push %esi
	push %edi

	/* stack
	*count
	**mat
	max_k
	*cur_comb
	k
	len
	*items

	ebp
	i
	*/

	.equ count, (8*ws)
	.equ mat, (7*ws)
	.equ max_k, (6*ws)
	.equ cur_comb, (5*ws)
	.equ k, (4*ws)
	.equ len, (3*ws)
	.equ items, (2*ws)
	# ret address
	# prologue
	.equ i, (-1*ws)

	# if(k == 0)
	movl k(%ebp), %eax # eax = k
	is0:
		cmpl $0, %eax
		jnz else_if

		# store_ar(cur_comb, max_k, mat, count);
		movl count(%ebp), %ebx # push count for store_ar
		push %ebx
		movl mat(%ebp), %esi # push mat for store_ar
		push %esi
		movl max_k(%ebp), %ecx # push max_k for store_ar
		push %ecx
		movl cur_comb(%ebp), %edx # push cur_count for store_ar
		push %edx
		# save ecx before function call? GCC - ECX

		movl %eax, %edi # save eax to edi
		call store_ar
		movl %edi, %eax # restore eax after function call
		addl $4*ws, %esp # clear arguments

		# restore ecx, edx 
		movl max_k(%ebp), %ecx # push max_k for store_ar
		movl cur_comb(%ebp), %edx # push cur_count for store_ar

		jmp else_if

	else_if:
		# len < k 
		# len - k < 0 
		# neg: len - k >= 0
		cmpl %eax, len(%ebp)
	 	jge else
		jmp _combs_epilogue

	else:
		#edi is i
		#for(i = 0; i < len; i++)
		movl $0, %edi
		else_loop:
			cmpl len(%ebp), %edi
			jge done_loop1

			# we are now inside the for loop
			# cur_comb[max_k - k] = items[i]
			movl items(%ebp), %esi # esi will be items
			movl (%esi,%edi,ws), %esi # esi = items[i] 

			movl k(%ebp), %eax # eax = k
			movl cur_comb(%ebp), %edx # edx = cur_comb
			movl max_k(%ebp), %ecx # ecx = max_k
			subl %eax, %ecx # ecx = max_k - k

			# movl (%edx,%ecx, ws), %eax # eax = cur_comb[max_k - k]
			movl %esi, (%edx,%ecx, ws) # cur_comb[max_k - k] = items[i]

			# _combs(items + i + 1, len - i - 1,  k - 1, cur_comb, max_k, mat, count); 
			movl count(%ebp), %ebx # push count for _combs
			push %ebx
			movl mat(%ebp), %esi # push mat for _combs
			push %esi
			movl max_k(%ebp), %ecx # push max_k for _combs
			push %ecx
			movl cur_comb(%ebp), %edx # push cur_count for _combs
			push %edx
			movl k(%ebp), %eax # push k for _combs
			decl %eax # k - 1  
			push %eax
			movl len(%ebp), %ebx # push len for _combs
			decl %ebx # len - 1
			subl %edi, %ebx # len - i
			push %ebx 
			movl items(%ebp), %esi # push items for _combs
			leal 4(%esi,%edi,ws), %esi # items + 1 +1
			push %esi
			call _combs # return value placed in EAX

			addl $7*ws, %esp # clear arguments

			jmp end_else_loop

		end_else_loop:
			incl %edi # edi++
			jmp else_loop

	done_loop1:

_combs_epilogue:
	pop %edi
	pop %esi
	pop %ebx
	movl %ebp, %esp
	pop %ebp
	ret

/*
void combs(int* items, int len, int k, int** mat){
  //the outward facing function that should be called
  //prints out all of the combinations of list taken k at a time
  //@items: the list of elements
  //@len: the number of elements in the list
  //@k: the number of elements per combination
  
  int zero;
  int* count = &zero;
  *count = 0;

  int *cur_comb = (int*) malloc(k*sizeof(int)); //make space for a combination
  _combs(items, len, k, cur_comb, k, mat, count); //create the combinations
  free(cur_comb);//free up the space malloced
}
*/

combs:
combs_prologue:
	push %ebp
	movl %esp, %ebp
	subl $3*ws, %esp # subtract space for locals
	#save registers 
	#save registers which are not eax, ecx, edx
	push %ebx
	push %esi
	push %edi

	/* stack
	**mat
	k
	len
	*items
	ret address

	ebp
	*cur_comb
	zero
	count
	*/

	.equ mat, (5*ws)
	.equ k, (4*ws)
	.equ len, (3*ws)
	.equ items, (2*ws)
	# ret addr
	# prologue
	.equ cur_comb, (-1*ws)
	.equ zero, (-2*ws)
	.equ count, (-3*ws)

  	/*
  	int zero;
  	int* count = &zero;
  	*count = 0;
	*/

	# leal to get address of count
	leal zero(%ebp), %eax # eax = &zero
	movl %eax, count(%ebp)
	movl $0, (%eax) # zero = 0

	# int *cur_comb = (int*) malloc(k*sizeof(int)); //make space for a combination
	movl k(%ebp), %ebx
	shll $2, %ebx
	push %ebx

	call malloc
	movl %eax,cur_comb(%ebp) # eax = cur_comb

	addl $1*ws, %esp #clear arguments
	

	# _combs(items, len, k, cur_comb, k, mat, count);
	movl count(%ebp), %ebx # push count for _combs
	push %ebx
	movl mat(%ebp), %esi # push mat for _combs
	push %esi
	movl k(%ebp), %ecx # push max_k for _combs
	push %ecx
	movl cur_comb(%ebp), %edx # push cur_count for _combs
	push %edx
	movl k(%ebp), %ecx # push k for _combs # not necessary
	push %ecx
	movl len(%ebp), %ebx # push len for _combs
	push %ebx 
	movl items(%ebp), %esi # push items for _combs
	push %esi
	call _combs # return value placed in EAX

	addl $7*ws, %esp #clear arguments

	movl cur_comb(%ebp), %edx # push cur_count for free
	push %edx
	# call free
	addl $1*ws, %esp # clear arguments

combs_epilogue:
	pop %edi
	pop %esi
	pop %ebx
	movl %ebp, %esp
	pop %ebp
	ret

/*
int** get_combs(int* items, int k, int len){

  int** mat = (int**)malloc(num_combs(len, k) * sizeof(int*));

  int row, col, temp;
  temp = num_combs(len, k);

  // allocate space for the new matrix
  for(row = 0; row < temp; ++row) {
      mat[row] = (int*)malloc(k * sizeof(int));
        for(col = 0; col < k; ++col) {
        }
  }

  combs(items,len,k, mat);

  return mat;
}
*/

get_combs:
get_combs_prologue:
	push %ebp
	movl %esp, %ebp
	subl $4*ws, %esp # subtract space for locals
	#save registers
	push %ebx
	push %edi
	push %esi
	
	/* stack
	len
	k
	*items
	ret address

	ebp
	**mat
	row
	col
	temp
	*/

	.equ len, (4*ws)
	.equ k, (3*ws)
	.equ items, (2*ws)
	# ret addr
	# prologue
	.equ mat, (-1*ws)
	.equ row, (-2*ws)
	.equ col, (-3*ws)
	.equ temp, (-4*ws)

	# int** mat = (int**)malloc(num_combs(len, k) * sizeof(int*));
	# put arguments on the stack
	movl k(%ebp), %eax
	push %eax
	movl len(%ebp), %ebx
	push %ebx
	call num_combs
	# num_combs stored in eax

	movl %eax, %ecx # ecx = num_combs(len, k)
	shll $2, %eax
	push %eax

	# save eax
	movl %eax, %ebx

	call malloc
	movl %eax, mat(%ebp)  # ecx = mat
	# restore eax
	movl %ebx, %eax

	addl $1*ws, %esp #c lear arguments

	# temp = num_combs(len, k);
	movl k(%ebp), %eax
	push %eax
	movl len(%ebp), %ebx
	push %ebx
	call num_combs
	# eax has temp

	# for(row = 0; row < temp; ++row) {
	# edx is row
	movl $0, %edx
	for_loop:
		cmpl %eax, %edx
		jge end_loop

	# mat[row] = (int*)malloc(k * sizeof(int));
		movl %edx, row(%ebp)
		movl k(%ebp), %ebx # ebx = k
		shll $2, %ebx
		push %ebx

		# store eax and edx before malloc
		movl %eax, %esi
		movl %edx, %edi
		call malloc
		# movl %edi, %edx # restore row
		movl %eax, %ecx # store address in ecx
		movl mat(%ebp), %eax # eax = mat
		movl row(%ebp), %edx # ecx = mat[row]
		movl %ecx, (%eax, %edx, ws) # memory at ecx, add edx * ws
		
		# restore eax and edx
		movl %esi, %eax
		movl %edi, %edx

		addl $1*ws,%esp # subract arguments from stack

		jmp end_for_loop

		end_for_loop:
		incl %edx
		jmp for_loop

	end_loop:


	# combs(items,len,k, mat);
	movl mat(%ebp), %esi # push mat for combs
	push %esi
	movl k(%ebp), %eax # push k for combs
	push %eax
	movl len(%ebp), %ebx # push len for combs
	push %ebx 
	movl items(%ebp), %esi # push items for _combs
	push %esi
	call combs

	addl $4*ws, %esp # clear arguments

	movl mat(%ebp), %eax # return mat

	get_combs_epilogue:
		pop %esi
		pop %edi
		pop %ebx
		movl %ebp, %esp
		pop %ebp
		ret
