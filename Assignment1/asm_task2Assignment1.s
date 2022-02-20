section	.rodata			; we define (global) read-only variables in .rodata section
	format_string: db "%s", 10, 0	; format string
	format_digit: db "%d", 10, 0	; format string

section .bss			; we define (global) uninitialized variables in .bss section
	result: resb 1		
section .data
	reValue: db 0 ; local variable to count the number of bits in input 
	err: db 'illegal input'
section .text
	global assFunc
	extern printf
	extern c_checkValidity

assFunc:
	push ebp
	mov ebp, esp
	pushad			
	mov edx, dword [ebp+8]	; get x
	mov ecx, dword [ebp+12]	; get y
	mov ebx, edx
	add ebx, ecx
	push ecx
	push edx
	call c_checkValidity
	mov [result], eax
	add esp, 8
	cmp byte [result], 48
	je endLoop1
	push ebx			; call printf with 2 arguments -  
	push format_digit	; pointer to str and pointer to format string
	call printf
	add esp, 8			; clean up stack after call
	jmp endLoop2

	endLoop1:
		push err			; call printf with 2 arguments -  
		push format_string	; pointer to str and pointer to format string
		call printf
		add esp, 8			; clean up stack after call
	endLoop2:

	popad			
	mov esp, ebp	
	pop ebp
	ret
