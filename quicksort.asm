

.data

buffer: .space 600
testbuff: .asciiz "99 68 67 9 8 0 1 22 66 65" 
array: 	.word 0:2048
newbuff: .space 600
endprogrambuff: .asciiz "The program has ended\n" 
clearArrandBuff: .asciiz "The array is reinitialized enter your numbers again\n" 
newline: .asciiz "\n" 
welcomeMessage: .asciiz "Welcome to Quicksort\n" 
sortedArrayMessage: "The sorted array is: " 
arrayElementsMessage: "The elements of the array are: " 
error: "Invalid input program terminating" 


	.text
	.globl main

main:	
	la $a0,welcomeMessage
	jal writetoMMIO
	la $s0,array		#s0 is a pointer to the first free spot in the array 
	add $s1,$0,$0		#s1 is the length of the array 
mainloop: 
	la $a0,buffer
	jal readfromMMIO
	
	la $a0,buffer
	jal determineCommand
	add $s3,$v0,$0
	
	beq $s3,'q',endprogram
	beq $s3,'c',clearArrayandBuffer
	beq $s3,'s',displaySortedArray
	
errormessage: 
	la $a0,error
	jal writetoMMIO
	
	li $v0,10 
	syscall
	
endprogram: 
	la $a0,endprogrambuff
	jal writetoMMIO
	
	li $v0,10 
	syscall 
clearArrayandBuffer: 
	
	la $a0,newbuff		#clear buffers and array
	jal clearBuffer
	
	la $a0,array
	jal clearArray
	
	la $a0,buffer
	jal clearBuffer
	
	la $a0,clearArrandBuff
	jal writetoMMIO
	
	la $s0,array		#s0 is a pointer to the first free spot in the array 
	add $s1,$0,$0		#s1 is the length of the array 
	
	j mainloop 
	
displaySortedArray: 

	la $a0,buffer		#put buffer into an array 
	add $a1,$s0,$0		#a1 is a pointer to the first free spot in the array
	add $a2,$s1,$0		#a2 is a pointer to the num of elements in the array 
	jal bufferToArray 
	add $s0,$v0,$0		#s0 is a pointer to the first free spot in the array 
	add $s1,$v1,$0		#s1 is the length of the array
	
	la $a0,newbuff		#store unsorted array in newbuff		
	la $a1,array
	add $a2,$s1,$0
	jal arrayToBuffer 
	
	la $a0,arrayElementsMessage
	jal writetoMMIO
	
	la $a0,newbuff		#display	
	jal writetoMMIO 
		
	la $a0,newline		#print a newline 
	jal writetoMMIO
	
	la $a0,newbuff		#clear the newbuffer
	jal clearBuffer
	
	la $a0,array		#quicksort the array
	add $a1,$0,$0
	addi $a2,$s1,-1
	jal quicksort 
	
	la $a0,newbuff		#store the sorted array in a buffer 			
	la $a1,array
	add $a2,$s1,$0
	jal arrayToBuffer

	la $a0,sortedArrayMessage	#print message 
	jal writetoMMIO 
	
	la $a0,newbuff			#print sorted array 
	jal writetoMMIO 
	
	la $a0,newline
	jal writetoMMIO
	
	la $a0,newbuff			#clear newbuffer
	jal clearBuffer
	
	la $a0,buffer			#clear old buffer 
	jal clearBuffer
	
	j mainloop 			#repeat 

	

bufferToArray: 
#pointer to buffer in a0 
#pointer to first freespot in array is in a1 
#a2 is the number of elements in the array
#convert characters to integers and store them in an array 
#return pointer to next free element in the array in $v0 
#return value of number of elements in the array in $v1 

	add $t0, $a1,$0		#t0 is a pointer to the array 
	add $t1,$a0,$0		#t1 is a pointer to the buffer
	add $t2,$a0,$0		#t2 is a pointer to the buffer
	addi $t2,$t2,1		#increment t2 by 1
	
putbufferintoarray: 
	lb $t3,($t1)		#loop through buffer
	beq $t3,$0,finished	#if you are at the end of the file exit loop
	beq $t3,'<',finished 
	beq $t3,' ', continue 	#if you encounter a space, continue 
	blt $t3,'0',continue
	bgt $t3,'9',continue
	
#t3 is now an integer if you reach this stage 

	lb $t4,($t2)		#check if the next character is also a number if it is not jump to one digit
	beq $t4,' ', onedigit 
	beq $t4,$0,onedigit	
	blt $t4,'0',onedigit
	bgt $t4,'9',onedigit
	beq $t4,$0,onedigit
	
#t3 and $t4 are both digits if you reach this stage
	addi $t3,$t3,-48	#get integer values of digits
	addi $t4,$t4,-48	
	
	addi $t5, $0,10
	mul $t3,$t3,$t5		#multiply first digit by 10
	
	add $t6,$t3,$t4		#add the two digits to get the two digit integer 	
	
	sw $t6,($t0)		#store digit in the array
	addi $a2,$a2,1		#increment numelements in array 
	addi $t0,$t0,4		#increment array pointer
	
	addi $t1,$t1,2		#increment both pointers by two
	addi $t2,$t2,2
	j putbufferintoarray
	
onedigit:
	addi $t3,$t3,-48	#get integer value of character
	sw $t3,($t0)		#store integer into array 
	addi $a2,$a2,1		#increment numelements in array 
	addi $t0,$t0,4		#increment array pointer
	
	addi $t1,$t1,1		#increment both pointers by one
	addi $t2,$t2,1
	j putbufferintoarray
	
continue:
	addi $t1,$t1,1		#increment both pointers by one
	addi $t2,$t2,1
	j putbufferintoarray	#repeat
	
finished: 			
#now integers are in the array, have to return a pointer to the next free element in $v0 and numelements in array in $v1
	add $v0,$t0,0
	add $v1,$a2,$0
	jr $ra 



clearArray: 
#pointer to array is in a0 
#return numelements (should be 0) 
	add $t0,$0,$0 		#make a counter=0
	add $t1,$0,$0		#let t1=0
loop2048: 
	beq $t0,2048,stoploop2048
	sw $t1,($a0)		#store 0 in array
	addi $t0,$t0,1		#increment counter 
	addi $a0,$a0,4		#go to next element in array 
	j loop2048
stoploop2048: 
	addi $v0,$v0,0
	jr $ra 
	


arrayToBuffer: 
#pointer to buffer is in a0
#pointer to array in a1 
#numelements in array in a2
#loop to end of buffer to find where we should write elements of the array 

loopToEnd: 
	lb $t0,($a0)			#get character of buffer
	beq $t0,$0,atEnd 		#if you reach a null character you are at the end
	addi $a0,$a0,1			#else increment a0
	j loopToEnd
atEnd:
#a0 now points to the end of the buffer (ie first free spot to write to) 

	addi $t0,$0,0			#make a counter

storearraytobuffer: 
	beq $t0,$a2,stop		#loop num of elements in array times 
	lb $t7,($a1)			#get byte of array
	
	blt $t7,10,addonedigit 		#if number is less than 10 jump to add one digit 
	
#else number is two digits 
	addi $t9,$0,10			#split the number into two digits and store each digit in the buffer
	div $t7,$t9
	mflo $t1
	mfhi $t2
	addi $t1,$t1,48
	addi $t2,$t2,48
	sb $t1,($a0)
	addi $a0,$a0,1
	sb $t2,($a0)
	j cont 
	
addonedigit: 
	addi $t7,$t7,48			#store the ascii value of the digit in the buffer
	sb $t7,($a0)
	j cont 
	
cont:
	addi $a1,$a1,4			#go to next element in array
	addi $a0,$a0,1			#increment buffer pointer
	addi $t7,$0,32			#add a space
	sb $t7,($a0)		
	addi $a0,$a0,1			#increment buffer pointer again
	addi $t0,$t0,1			#increment counter
	j storearraytobuffer		#repeat
stop:	
#buffer now contains array elements 
	jr $ra 		#return

printString: 
#pointer to string in a0
	li $v0,4
	syscall 
	jr $ra 
	
printInt: 
#number is in a0
	li $v0,1
	syscall 
	jr $ra
	
swap: 
#pointer to array in a0 
#i in a1
#j in a2
	mul $a1,$a1,4		#mumtiply i by 4
	mul $a2,$a2,4		#multiply j by 4
	add $t6,$a0,$a1		#t6 pointer to array[i]
	add $t7,$a0,$a2		#t7 pointer to array[j]
	lw $t8,($t6)		#t8=array[i]
	lw $t9,($t7)		#t9=array[j]
	sw $t8,($t7)		#store array[i] at position j 
	sw $t9,($t6)		#store array[j] at position i
	jr $ra			#return  

partition: 
#a0 is a pointer to the array 
#a1 =low
#a2= hi 
	addi $sp,$sp,-16		#save arguments and registers to the stack 
	sw $a0,($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $ra,12($sp)
	
	add $t4,$a1,$0			#t4=p_pos=low
	
	mul $t0,$t4,4			#set t0 as a pointer to the array at low
	add $t0,$t0,$a0	
		
	lw $t1,($t0)			#t1=pivot=array[low] 
		
	addi $t2,$a1,1			#t2=low+1
partitionloop: 
	lw $a2,8($sp)			#check if t2>hi. if so end loop
	bgt $t2,$a2,endpartitionloop 
	
	lw $a0,($sp)			#a0 is pointer to the array 
	mul $t3,$t2,4			#set t3 as a pointer to array[t2]
	add $t3,$t3,$a0			
	lw $t3,($t3)			#t3=array[t2]
	
	bge $t3,$t1,continuepartitionloop	#if array[t2] !< pivot continue to next iteration 
	addi $t4,$t4,1				#else p_pos++
	lw $a0,($sp) 				#swap(array,p_pos,t2) 
	add $a1,$t4,$0
	add $a2,$t2,$0	
	jal swap 
continuepartitionloop: 
	addi $t2,$t2,1				#increment counter and continue 
	j partitionloop 

endpartitionloop: 
	lw $a0,($sp) 
	lw $a1,4($sp)
	add $a2,$t4,$0
	jal swap 		#swap(array,low,p_pos) 
	
	
	lw $a0,($sp)		#restore arguments and restore stack 
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $ra,12($sp)
	addi $sp,$sp,16	
	add $v0,$0,$t4		#return p_pos
	jr $ra 
	
quicksort: 
#pointer to array in a0 
#a1=low
#a2=hi 
	
	addi $sp,$sp,-16	#else save registers and arguments to stack 
	sw $a0,($sp)
	sw $a1,4($sp)
	sw $a2,8($sp)
	sw $ra,12($sp)
	
	ble $a2,$a1,return 	#if hi<=low return 
	
	lw $a0,($sp)	
	lw $a1,4($sp)
	lw $a2,8($sp)
	jal partition 
	
	add $t5,$v0,$0		#pivot=partition(array,low,hi) 
	
	lw $a0,($sp)		
	lw $a1,4($sp)
	addi $a2,$t5,-1
	jal quicksort 		#quicksort(array,low,pivot-1)
	
	lw $a0,($sp)		
	addi $a1,$t5,1
	lw $a2,8($sp)
	jal quicksort 		#quicksort(array,pivot+1,hi)	
	
return: 
	
	lw $a0,($sp)
	lw $a1,4($sp)
	lw $a2,8($sp)
	lw $ra,12($sp)
	addi $sp,$sp,16		#restore arguments and stack pointer 
	jr $ra 

	
writetoMMIO: 
#pointer to string is in a0 
	lui $t0, 0xffff 	#ffff0000
Loop1: 	lw $t1, 8($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1
Loop2:
	lb $t2,($a0)
	beq $t2,$0,endloop2
	beq $t2,'<',endloop2
	sb $t2, 12($t0) 	#data	
	addi $a0,$a0,1
	j Loop2
endloop2: 
	jr $ra

		
readfromMMIO:
#a0 is the buffer you would like to write to
	add $t2,$0,$0			#make a counter=0 
echo:	
	lui $t0, 0xffff 		#ffff0000
Loop3:	lw $t1, 0($t0) 			#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop3
	lw $v0, 4($t0) 			#data	
 		
	beq $t2,600,stopReading		#if you have read 600 characters stop 
	beq $v0,'\n',stopReading	#or if user presses enter stop 
	sb $v0,($a0)			#store character in buffer
	addi $a0,$a0,1			#increment buffer pointer by 1 
	addi $t2,$t2,1			#increment counter by 1 
	j echo				#repeat infinetely many times 	
stopReading: 
	jr $ra 	
	
determineCommand: 
#pointer to buffer is in a0 
#return command in v0 
loopToCommand: 
	lb $t0,($a0)			#get character of buffer
	beq $t0,'<',atCommand 		#if you reach a < the next character is the command
	beq $t0,$0,errorCommand		#if user doesnt enter anything in brackets 
	addi $a0,$a0,1			#else increment a0
	j loopToCommand
atCommand:  
	addi $a0,$a0,1			#increment pointer by 1 to get to the command 
	lb $t0,($a0)			#get ascii value of command 
	addi $v0,$t0,0			#store it in v0
	jr $ra 				#return 
errorCommand:
	j errormessage
	
clearBuffer: 
#pointer to buffer in a0
	add $t1,$0,$0			#store t1 as constant 0 
loopthroughbuffer: 
	lb $t0,($a0)			
	beq $t0,$0,bufferisempty 	#if you encounter a null character buffer is already empty 
	sb $t1,($a0)			#store 0 at spot pointed to by a0
	addi $a0,$a0,1			#increment pointer 
	j loopthroughbuffer
bufferisempty: 
	jr $ra 				#return 

	

	
	
		
	
	
