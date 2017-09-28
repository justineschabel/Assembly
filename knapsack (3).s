#Knapsack C code
/*

unsigned int max(unsigned int a, unsigned int b){
  //computes the max of a and b
  return a > b ? a : b;
}

unsigned int knapsack(int* weights, unsigned int* values, unsigned int num_items, 
              int capacity, unsigned int cur_value){
  
  solves the knapsack problem
  @weights: an array containing how much each item weighs
  @values: an array containing the value of each item
  @num_items: how many items that we have
  @capacity: the maximum amount of weight that can be carried
  @cur_weight: the current weight
  @cur_value: the current value of the items in the pack
  
  unsigned int i;
  unsigned int best_value = cur_value;
  
  for(i = 0; i < num_items; i++){//for each remaining item
    if(capacity - weights[i] >= 0 ){//if we can fit this item into our pack
      //see if it will give us a better combination of items
      best_value = max(best_value, knapsack(weights + i + 1, values + i + 1, num_items - i - 1, 
                     capacity - weights[i], cur_value + values[i]));
    }//if we can fit this item into our pack   
  }//try to find the best combination of items among the remaining items
  return best_value;


}*/

#Knapsack Assembly Code

.global knapsack


.equ ws, 4	#word_size is 4

.text 

#unsigned int max(unsigned int a, unsigned int b)
max: 
	#edx is used as a temporary register and eax will have the return value. They do not have live values so they do  not need to be put onto the stack

	prologue_max:
		push %ebp
		movl %esp, %ebp
		
	/*
	stack:
	b
	a
	ret	
	ebp
	*/

	.equ a, (2*ws)
	.equ b, (3*ws)

	#return a > b ? a : b;	
	movl b(%ebp), %edx		#move b into edx as a temporary holder		
	cmpl %edx, a(%ebp)		#a-b
	jle b_bigger			#if b is bigger, jump to b_bigger
	movl a(%ebp), %eax		#a is bigger so move it to eax
	
	b_bigger:
	movl b(%ebp), %eax		#b is bigger so move it to eax

	epilogue_max:
	movl %ebp, %esp
	pop %ebp
	ret			

#unsigned int knapsack(int* weights, unsigned int* values, unsigned int num_items, int capacity, unsigned int cur_value){
knapsack:

	#edx is often used as a placeholder to do calculations. eax is i. esi is used to do a subtraction(so another temporary placeholder)
	prologue:
		push %ebp
		movl %esp, %ebp
		subl $2*ws, %esp 	#subtract space for locals: i, best_value
	
		push %esi		#save registers
		push %ebx
		
		/*stack
		cur_value
		capacity
		num_items
		values
		weights
		ret address
		
		ebp
		i
		best_value
		esi
		ebx
		*/

	
	.equ best_value, (-2 *  ws)
	.equ i, (-1 * ws)
	.equ weights, (2 * ws)
	.equ values, (3 * ws)
	.equ num_items, (4 * ws)
	.equ capacity, (5 * ws)
	.equ cur_value, (6 * ws)
	

	#best_value = cur_value;
	movl cur_value(%ebp), %edx	#edx = cur_value
	movl %edx, best_value(%ebp)	#best_value = edx = cur_value


	movl $0, %eax		#reset eax for every function call 
	
	
	#for(i = 0; i < num_items; i++)
	loop:
		cmpl num_items(%ebp), %eax	#i- num_items 
		jg end_loop			# if i > num_items end loop 
	
		#if(capacity - weights[i] >= 0 )
		movl weights(%ebp), %ebx 	#ebx = weights (this is a pointer)
		movl (%ebx, %eax, ws), %ebx	#ebx = weights[i]  (This is a value)
		cmpl  %ebx, capacity(%ebp)	#capacity - weights[i] 
		jl end_if			#if weights[i] is bigger weve reached the bags limit, increment i and go through the loop again

			#best_value = max(best_value, knapsack(weights + i + 1, values + i + 1, num_items - i - 1, capacity - weights[i], cur_value + values[i]));	
			
			#push knapsack arguments in reverse order
 
			#cur_value + values[i]
			movl values(%ebp), %edx			#edx will be our temporary register here: edx = values
			movl (%edx, %eax, ws), %edx		#edx is values[i]
			addl cur_value(%ebp), %edx 		#edx = cur_value + values[i] 
			push %edx 				#put cur_value + values[i] on the stack
		

			#capacity - weights[i]
			movl weights(%ebp), %edx		#edx will be a temp reg again: edx = weights(pointer)
			movl (%edx, %eax, ws), %edx		# edx = weights + i
			movl capacity(%ebp), %esi		#esi is  temp reg. Set to 0
			subl %edx, %esi				#This puts -weights[i] in esi
			push %esi				#put capacity - weights[i] onto the stack
		
			#num_items - i - 1
			movl num_items(%ebp), %edx		#edx is a temp reg: edx = num_items
		 	subl %eax, %edx				#num_items - i
			subl $1, %edx				#num_items - i - 1
			push %edx				#put it on the stack
			
			#values + i + 1
			movl values(%ebp), %edx			#edx is a temp reg, edx = values
			leal 1*ws(%edx, %eax, ws), %edx		#values + i + 1 (this is an address)
			push %edx				#push values + i + 1 onto the stack
		
			#weights + i + 1
			movl weights(%ebp), %edx		#edx is a temp reg, edx = weights
			leal 1*ws(%edx, %eax, ws), %edx		#edx + i + 1 
			push %edx				#push weights + i + 1 onto the stack
			

			#save eax
			movl %eax, i(%ebp)			#we will loose eax's value so we need to save it and restore it later 

			#knapsack(weights + i + 1, values + i + 1, num_items - i - 1, capacity - weights[i], cur_value + values[i])
			call knapsack				#the return value is in ebx
			
			#push args for max onto the stack 
			push %ebx				#put the return value from knapsack onto the stack
			movl best_value(%ebp), %edx		#edx = best_value
			push %edx				#push best_value onto the stack

			#max(best_value, knapsack(weights + i + 1, values + i + 1, num_items - i - 1, capacity - weights[i], cur_value + values[i]))
			call max				
	

			cmpl best_value(%ebp), %eax		#eax - best_value
			jg move					#if the new value is greater than best_value replace it 
			jmp restore				#otherwise try another combination
			
			move:
			movl %eax, best_value(%ebp)		#best_value = max(best_value, knapsack()) 

			restore:
			movl i(%ebp), %eax			#resore i
			
		
		end_if:
			incl %eax	#i++
			jmp loop	#go through the next loop 

	end_loop:

	movl best_value(%ebp), %eax

	epilogue:
		pop %ebx
		pop %esi
		addl $2, %esp
		movl %ebp, %esp
		pop %ebp
		ret
done:
	movl %eax, %eax
		
	
		





