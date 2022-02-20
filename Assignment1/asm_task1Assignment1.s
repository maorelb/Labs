section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string
section .bss			; we define (global) uninitialized variables in .bss section
	an: resb 12		; enough to store integer in [-2,147,483,648 (-2^31) : 2,147,483,647 (2^31-1)]
section .data
	counter: dd 0 ; local variable to count the number of bits in input 
	flag: db 0
	table: 	dd 1 ; locall array to hold power of two up to 2^31 
		    dd 2
			dd 4
			dd 	8
			dd 	16
			dd 	32
			dd 	64
			dd 	128
			dd 	256
			dd 	512
			dd	1024
			dd	2048
			dd	4096
			dd	8192
			dd	16384
			dd	32768
			dd	65536
			dd	131072
			dd	262144
			dd	524288
			dd	1048576
			dd	2097152
			dd	4194304
			dd	8388608
			dd	16777216
			dd	33554432
			dd	67108864
			dd	134217728
			dd	268435456
			dd	536870912
			dd	1073741824
			dd	2147483648
section .text
	global convertor
	extern printf

convertor:
	push ebp
	mov ebp, esp	
	pushad			

	mov ecx, dword [ebp+8]	; get function argument (pointer to string)
	mov edx, dword [ebp+8]
	mov byte [flag], 0
	calculate_length:
		cmp byte [edx], 10
		je makeZero
		inc byte [counter]
		inc edx
		jmp calculate_length
	
	makeZero:
		mov eax,0

	continue1:
		cmp byte [counter], 32
		je decrement
		cmp byte [counter],0
		jnz increment
		jmp preDivision
	
	decrement:
		dec byte [counter]
		mov ebx, [counter]
		sub eax,[table + ebx*4]
		inc ecx
		jmp continue1
	
	increment:
		dec byte [counter]
		inc ecx
		cmp byte [ecx-1], 0x31
		je acc
		jmp continue1

	acc:
		mov ebx, [counter]
		add eax,[table + ebx*4]
		jmp continue1
	

	preDivision:
		mov ecx, 0
		mov ebx, 10
		cmp eax, 0
		jge division
		neg eax
		inc ecx
		mov byte [flag], 1
	
	division:
		mov edx, 0
		cmp eax, 0
		je checkNeg
		div ebx
		add edx, 48
		push edx
		inc ecx
		jmp division
	checkNeg:
		cmp byte [flag], 1
		jnz fillAN
		push 45

	fillAN:
		cmp edx, ecx
		je endLoop
		pop ebx
		mov [an + edx], ebx
		inc edx
		jmp fillAN

	endLoop:
		push an				; call printf with 2 arguments -  
		push format_string	; pointer to str and pointer to format string
		call printf
		add esp, 8			; clean up stack after call

	popad			
	mov esp, ebp	
	pop ebp
	ret
