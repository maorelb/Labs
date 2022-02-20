section .rodata
  format_string: db "%s",0
  format_digit: db "%d",0
  format_hex: db "%02X",0
  format_hex_no_zero: db "%X",0
  calc: db "calc: ",0
  operator_error_msg: db "Error: Insufficient Number of Arguments on Stack",10,0
  operand_error_msg: db "Error: Operand Stack Overflow",10,0
  Y_error_msg: db "Error: Y > 200",10,0
  endl: db 10,0
  s0: db "",0
  sdebug: db " - debug: ",0
  numOperations: db "num of operations:",0
  size equ 5

section .bss ;  we define (global) uninitialized variables in .bss section
  stack: resd size
  power: resb 25
  input: resb 81      ; Each input line is no more than 80 characters in length.
  num: resb 4
  numerr: resb 1
  car: resb 1
  address: resb 4
  length1: resb 4
  length2: resb 4
  num_of_operations: resb 10
  debugMode: resb 1
  num_elements: resb 10             ;number of elements currently in stack

section .data
  backup_ebp: db 4
  backup_esp: db 4
  
section .text
  align 16
     global main
     extern printf
     extern fprintf
     extern fflush
     extern malloc
     extern calloc
     extern free
     extern gets
     extern fgets 
     
main:
  %macro printMem 2
    pushad              ; print memoty location to stdout
    push %1 
    push %2 
    call printf
    add esp,8           ; clean up stack after call (4 for each pointer, 4 + 4 = 8).
    popad
  %endmacro
  
  %macro printerr 2
   pushad
   mov eax,4    ; system call number
   mov ebx,2    ; file descriptor - STDERR (2)
   mov ecx,%1    ; pointer to output buffer
   mov edx,%2     ; count of bytes to send 
   int 0x80
   popad
  %endmacro
  %macro restart 0
    mov eax,0         ;set all registers to 0
    mov ebx,0
    mov ecx,0
    mov edx,0
  %endmacro

  %macro free_first_operand_from_stack 0
    pushad
    mov ecx, [num_elements]
    dec ecx
    mov eax ,[stack +4*ecx]         ; push first argument - pointer to first node in stack[top]
    %%remove_next:
    mov esi, [eax +1]           ; esi = next node to be removed
    pushad
    push eax
    call free
    add esp,4 
    popad
    mov eax, esi              ; eax = eax.next
    cmp eax,0 
    je %%done_remove
    jmp %%remove_next
    %%done_remove:
    popad
    dec byte [num_elements]           ; num_elements --
  %endmacro

  ;calculate the length of the list pointed by argument to esi
  %macro calc_list_len 1        
    mov esi,0
    mov ebx,%1                  ;backup for original list pointer
    %%inc_esi:
      inc esi
      mov %1, [%1 +1]            ; next link   
      cmp %1,0                   ; reached end of the list 
      jne %%inc_esi
    mov %1,ebx
  %endmacro


  ; getting command line arguments:
  mov ecx, [esp+4]  ;argc
  mov edx, [esp+8]  ;argv
  mov [backup_ebp],ebp
  mov [backup_esp],esp 
  mov byte [num_elements],0
  mov byte [debugMode],0
  mov byte [num_of_operations],0
  cmp ecx, 2
  je check_debug
  jne my_calc
  check_debug:
    mov eax,[edx+4]                 ; [edx] = program name.  [edx +4] = first argument               
    cmp word [eax], '-d'            ; debug mode is activated
    je debug_mode
    jmp start
  debug_mode:
    mov byte [debugMode],1
  
  start:
    cmp byte [debugMode], 1
    je pstderr
    jmp my_calc
    pstderr:
      cmp byte [num_elements], 0    ;nothing to print
      je my_calc
      
      printerr sdebug, 11       ; on debug mode - print the last operand pushed to stack
      pushad
      mov eax, [num_elements]
      dec eax
      mov edx, [stack +eax*4]
      call print_operand_err
      popad
      printerr endl, 2
  my_calc:
    printMem calc, format_string      ; print to the screen "calc: "
    pushad                            ; get an input fom stdin
    push input 
    call gets
    add esp,4 
    popad

    cmp byte [input],'q'    ; if 'q' received , exit
    je end_main
    cmp byte [input],'+'    ; '+' operator 
    je addition
    cmp byte [input],'p'
    je pop_and_print
    cmp byte [input],'^'
    je power_up
    cmp byte [input],'v'
    je power_down
    cmp byte [input],'n'
    je num_bits
    cmp byte [input],'d'
    je duplicate

    ;-----------------------------push an operand to stack by little endian order-------------------------------
  push_to_stack: 
      ; takes the char in bl and turn in to hex
      %macro modify_bl 0
        cmp bl, 58
        jl .sub_0
        jge .sub_55
        .sub_0:
        sub bl, '0'
        jmp .end
        .sub_55:
        sub bl, 55
        jmp .end
        .end:
      %endmacro
      ; takes the char in dl and turn in to hex
      %macro modify_dl 0
        cmp dl, 58
        jl .subb_0
        jge .subb_55
        .subb_0:
        sub dl, '0'
        jmp .endd
        .subb_55:
        sub dl, 55
        jmp .endd
        .endd:
      %endmacro
      
      restart
      cmp byte [num_elements],5
      je print_operand_error_msg     ; num_elements = 5 , stack overflow.
      mov esi,0              ; esi=counter
      mov edi,input          ; edi=pointer to input

      skip_leading_zeroes: 
        cmp byte [edi],'0'
        jne save_MSB_pos     ; reached first non-zero char
        inc edi
        jmp skip_leading_zeroes

      save_MSB_pos:
        mov ebx,0
        mov ebx,edi           ; ebx =pointer to MSB

      calc_len:               ; calculate length(excluding leading zeroes)
        cmp byte [edi],0
        jne inc 
        je end_calc_len
        inc:
          inc esi              ; counter++
          inc edi              ; edi now points to next digit
          jmp calc_len

      end_calc_len:            ; check if length is even
        mov edx, 0  
        mov eax, esi  
        mov ecx,0
        mov ecx, 2 
        div ecx                ; divide eax value by 2
        cmp edx ,0
        jne create_single_node    ;if length is odd create a single node first containg : [(MSB 0)]
        je otherwise

      create_single_node:
        mov ecx, esi           ; number of iterations = length
        mov esi,0              ; esi = current node in stack[num_elements] , initialized to 0
        mov edi,ebx            ; edi= pointer to MSB
        mov ebx, 0   ; n
        mov bl, [edi]          ; bl (next digit) gets the MSB
        inc edi                ; edi now points to next digit
        modify_bl
        jmp create_node
      
      otherwise:
        mov ecx, esi             ; number of iterations = length
        mov esi,0                ; esi = current node in stack[num_elements] , initialized to 0
        mov edi,ebx              ; edi= pointer to MSB

      iterate:           ; iterate the input(Big endian order) 
        mov ebx,0 ; n
        mov bl, [edi]          ; bl = next digit
        modify_bl
        inc edi                ; edi now points to next digit
        mov dl, [edi]          ; dl=following digit
        modify_dl
        inc edi                ; edi now points to next digit
        shl bl, 4              ; multipy first digit by 16
        add bl, dl             ; bl now contains the decimal value
        dec ecx                ; ecx-- 
        jmp create_node        ; create a node for each sequential digits
        after_creation:
          loop iterate,ecx

      insert_linkedList_to_stack:       ; at this point input was converted to linked list 
        mov ebx, [num_elements]         ; ebx = number of elements in stack
        mov [stack +4*ebx],eax          ; insert the new created linked list at stack[top]
        inc byte [num_elements]         ; num_elements++
        jmp start                        ; go back to main 

      create_node:   
        push ecx                ; backup ecx
        push 5                 ; push first argument - request 5 bytes to be allocated
        call malloc
        add esp, 4             ; clean space created for argument
        pop ecx                ; restore ecx
        mov byte [eax],0
        mov dword [eax+1],0
        mov byte [eax],bl      ; insert the operand at the first byte in memory returned
        
        cmp esi,0              ; stack[num_elements].isEmpty() ?  
        je first_Node          ; isEmpty()==true
        jne concat             ; concat the new node to the current node(=esi) [newNode.next=currentNode]
      first_Node:
        mov esi,eax            ; currentNode=newNode  
        jmp after_creation
      concat:
        mov dword [eax+1],esi  ; save the address of the current node in the last 4 bytes of the new node 
        mov esi,eax            ; currentNode=newNode  
        jmp after_creation


  print_operator_error_msg:
    printMem operator_error_msg, format_string
    inc byte [num_of_operations]  
    jmp start

  print_operand_error_msg:
    inc byte [num_of_operations]  
    printMem operand_error_msg, format_string 
    jmp start
  ;----------------------pop two operands from operand stack, and push one result, their sum--------------------
  addition:
    cmp byte [num_elements],1
    jle print_operator_error_msg      ; num_elements <=1 
    inc byte [num_of_operations]  
    mov ecx, [num_elements]           ; ecx = num of elements 
    dec ecx                           ; num_elements --
    mov edi, [stack + 4*ecx]          ; edi= address of first node in stack[top]
    calc_list_len edi                 
    mov [length1],esi                 ; length1 = length of the list in stack[top]
    dec ecx                           ; num_elements --
    mov edx, [stack +4*ecx]           ; edx = address of first node in stack[top-1]
    calc_list_len edx     
    mov [length2],esi                 ; length2 = length of the list in stack[top-1]
    mov ebx,[length1]                 ; compare between length1 and length2
    cmp ebx,[length2]
    jl case1                          ; length1 < length2 
    ja case3                          ; length1 >length2 
    jmp case2                         ; length1==length2 

    %macro add_digits 1                 ; perfom addition with carry %1 times
      clc                               ; clear carry flag
      %%add_next_two_digits:
      mov byte bl, [edi]                ; bl = next digit of list in stack[top]
      mov byte al, [edx]                ; al = next digit of list in stack[top-1]
      adc al,bl                         ; add the bytes + carry flag
      mov byte [edx],al                 ; write the sum to the list in stack[top-1]
      mov edx, [edx+1]                  ; edx = edx.next 
      mov edi, [edi+1]                  ; edi= edi.next
        loop %%add_next_two_digits,ecx
    %endmacro

    %macro create_carry_node 1           ; creates carry nodes and concat to %1
      pushad
      push 5              
      call malloc
      add esp, 4                    
      mov [address],eax
      popad
      mov ebx,[address]
      mov byte [ebx],1 
      mov dword [%1+1],ebx  
    %endmacro

    case1: 
      mov ecx,[length1]                     ; perfom length1 iterations
      add_digits ecx
      jc .add_carry
      jmp end_case1
        .add_carry:
          mov byte cl,[edx]                 ;add carry to next node
          add cl,1
          mov byte [edx],cl                 ; write result
          jc .add_carry_to_next_node        ; if there's carry add to next node 
          jmp end_case1                 
          .add_carry_to_next_node:
            cmp dword [edx+1],0             ; last node?
            je .last_carry_node
            mov edx, [edx+1]                ; get next
            jmp .add_carry
          .last_carry_node:
            create_carry_node edx
            jmp end_case1
    end_case1:  
        free_first_operand_from_stack   
        jmp start

    case2:
      mov ecx,[length1]                  ;perfom length1 iterations
      add_digits ecx
      jc .add_last_carry
      jmp end_case2
      .add_last_carry:
        mov ecx,[num_elements]
        dec ecx
        dec ecx
        mov edx, [stack +4*ecx]
        .get_next:               
          cmp dword [edx+1],0                     
          je .concat_here
          mov edx,[edx+1]                 ; get next
          jmp .get_next
          .concat_here:
            create_carry_node edx
            jmp end_case2
    end_case2:
        free_first_operand_from_stack
        jmp start

    case3: 
      mov ecx,[length2]                     ; perfom length2 iterations
      add_digits ecx
      jc .add_carry
      jmp .copy_rest
        .add_carry:
          mov byte cl,[edi]                 ;add carry to next node
          add cl,1
          mov byte [edi],cl                 ; write result
          jc .add_carry_to_next_node        ; if there's carry add to next node 
          jmp .copy_rest                 
          .add_carry_to_next_node:
            cmp dword [edi+1],0             ; last node?
            je .last_carry_node
            mov edi, [edi+1]                ; get next
            jmp .add_carry
          .last_carry_node:
            create_carry_node edi
            jmp .copy_rest
        .copy_rest:
          mov ecx,[num_elements]
          dec ecx
          mov edi, [stack +4*ecx]
          dec ecx
          mov edx, [stack +4*ecx]
          mov ecx,[length2]
          .get_next_top_list:                   ; go to last node in stack[top]
            mov edi,[edi+1]
            loop .get_next_top_list,ecx
          .get_next_lower_list:                  ; go to last node in stack[top-1]     
            cmp dword [edx+1],0                     
            je .done
            mov edx,[edx+1]                 
            jmp .get_next_lower_list
          .done:
            jmp .prepare_new_node
          .iterate_and_copy: 
            mov ebx,[address]     
            mov [edx+1],ebx               ; concat new node created from previous iteration
            mov cl,[edi]                  ; copy number
            mov byte [ebx], cl            ; write number to new node
            cmp dword [edi+1],0           ; no more nodes to be copied
            je end_case3
            mov edi, [edi+1]              ; next node to be copied
            mov edx, [edx+1]          
            jmp .prepare_new_node  

          .prepare_new_node:
            pushad
            push 5                    ; push first argument - request 5 bytes to be allocated
            call malloc               ; now eax has the address of the new memory allocated
            .debug6:
            add esp, 4                ; clean space created for argument
            mov [address],eax
            popad
            jmp .iterate_and_copy
    
      end_case3:
        free_first_operand_from_stack
        jmp start
  ;----------------------pop one operand from the operand stack, and print its value to stdout------------------
  pop_and_print:
    restart
    cmp byte [num_elements],1
    jl print_operator_error_msg      ; num_elements < 1 
    inc byte [num_of_operations]  
    
    mov eax, [num_elements]
    dec eax
    mov edx, [stack + 4*eax]      ; edx = pointer to the first node
    call print_operand
    
    printMem endl, format_string
    
    free_first_operand_from_stack   ; [num_elements]--
    
    jmp my_calc

  ;-----------------push a copy of the top of the operand stack onto the top of the operand stack---------------
  duplicate:
    restart
    cmp byte [num_elements],1
    jl print_operator_error_msg      ; num_elements < 1
    
    cmp byte [num_elements],5
    je print_operand_error_msg      ; num_elements = 5 , stack overflow.
    inc byte [num_of_operations]  

    
    ;create the first node, and insert it to the top of the stack:
    push edx
    push 5                    ; push first argument - request 5 bytes to be allocated
    call malloc               ; now eax has the address of the new memory allocated
    add esp, 4                ; clean space created for argument
    pop edx
    mov byte [eax],0
    mov dword [eax+1],0
    mov edx, [num_elements]
    mov [stack +4*edx], eax   ; insert the new created linked list at stack[top]
    dec edx
    mov ebx, [stack + 4*edx]  ; ebx = pointer to the first node in stack

    iterate_and_copy:
      mov ecx, 0
      mov cl,[ebx]                 ; move only the last byte (the number) of ebx to ecx
      mov byte [eax], cl
      mov ebx, [ebx+1]             ; ebx is now point to the next node
      cmp ebx, 0                   ; check if we reached the end of the list 
      jne prepare_new_node
      je last_node

    prepare_new_node:
      mov esi, eax
      push edx
      push 5                    ; push first argument - request 5 bytes to be allocated
      call malloc               ; now eax has the address of the new memory allocated
      add esp, 4                ; clean space created for argument
      pop edx
      mov byte [eax],0
      mov dword [eax+1],0
      mov dword [esi+1],eax     ; save the address of the current node in the last 4 bytes of the new node 
      jmp iterate_and_copy
    
    last_node:
      inc byte [num_elements]         ; num_elements++
      jmp start                        ; go back to main 
      
  power_up:
    restart
    cmp byte [num_elements],2
    jl print_operator_error_msg      ; num_elements < 2
    inc byte [num_of_operations]  

    ;-- check if Y > 200 (in decimal)---
    .check_validity:
      mov eax, [num_elements]
      dec eax
      dec eax
      mov ebx, [stack + 4*eax]      ; ebx = pointer to Y (the second node)
      mov edx,0
      mov dl, 201
      cmp byte dl, [ebx]
      jl .stage2
      printMem Y_error_msg, format_string
      jmp start
      .stage2:
      cmp byte [ebx+1],0
      je .vaild
      printMem Y_error_msg, format_string
      jmp start
      
    ;------------Y is Ok---------------
    .vaild:
      mov ecx, 0
      mov byte cl, [ebx]          ; now ecx = Y (could be only 1 byte because Y is less then 201)
      .power_loop:                ; loop from Y to 0
        cmp ecx, 0
        je .end
        .shift_loop:              ; looping over X
          pushad
          mov eax, [num_elements]
          dec eax
          mov ebx, [stack + 4*eax]      ; ebx = pointer to X
          mov edx, ebx
          call shifting_left      ; preform shl X, 1
        
        dec ecx
        jmp .power_loop
      .end:
        mov eax, [num_elements]
        dec eax
        mov edx, [stack + eax*4]
        mov ecx, 0
        call copy_operand                       ; copy the new X (stored in edx) to ecx
        free_first_operand_from_stack           ; pop X
        free_first_operand_from_stack           ; pop Y
        mov eax, [num_elements]             
        mov dword [stack + eax*4], ecx          ; push X*2^Y
        inc byte [num_elements]                 ; [num_elements]++
        jmp start

  ;------------------------------multiple the first operand on stack by 2---------------------------------------
  shifting_left:
    pushad
    mov byte [car], 0
    .mul_Xc:
      mov ecx, 0
      mov cl,[ebx]                 ; move only the last byte (the number) of ebx to ecx
      shl cl, 1
      jc .carrc
      jnc .ncarrc
      
    .carrc:                         ; if carry, save it in a special memory location
      printMem s0,format_string
      adc byte cl, [car]
      mov byte [car], 1
      
      jmp .continuec

    .ncarrc:
      ; if not carry:
      adc byte cl, [car]
      mov byte [car], 0
      jmp .continuec
      
    .continuec:
      mov byte [ebx], cl           ; insert the new shifted element
      cmp byte [ebx+1], 0          ; check if we reached the end of X 
      je .donec
      mov ebx, [ebx+1]             ; ebx is now point to the next node
      jmp .mul_Xc
    .donec:                        ; done with shifting, now chack if there is still a carry
      cmp byte [car], 1
      jne end 
      push 5                       ; if there is still a carry, malloc
      call malloc
      add esp, 4
      mov byte [eax],0
      mov dword [eax+1],0
      mov byte [eax], 1
      mov dword [ebx+1], eax    
    end:
      popad
      ret

  power_down:
    restart
    cmp byte [num_elements],2
    jl print_operator_error_msg      ; num_elements < 2
    inc byte [num_of_operations]  

    .check_validity:
      mov eax, [num_elements]
      dec eax
      dec eax
      mov ebx, [stack + 4*eax]      ; ebx = pointer to Y (the second node)

    .vaild:
      mov ecx, 0
      mov byte cl, [ebx]          ; now ecx = Y
      .power_loop:                ; loop from Y to 0
        cmp ecx, 0
        je .end
        .shift_loop:
          pushad
          mov eax, [num_elements]
          dec eax
          mov ebx, [stack + 4*eax]      ; ebx = pointer to X
          mov edx, ebx
          call shifting_right           ; preform shr X, 1
        dec ecx
        jmp .power_loop
      .end:
        mov eax, [num_elements]
        dec eax
        mov edx, [stack + eax*4]
        mov ecx, 0
        call copy_operand                       ; copy the new X (stored in edx) to ecx
        free_first_operand_from_stack           ; pop X
        free_first_operand_from_stack           ; pop Y
        mov eax, [num_elements]             
        mov dword [stack + eax*4], ecx          ; push X*2^(-Y)
        inc byte [num_elements]                 ; [num_elements]++
        jmp start

  ;------------------------------shift a whole operand to the right, ones---------------------------------------
  shifting_right:
    pushad
    mov esi, 0
    mov byte [car], 0
    .first:
      mov ecx, 0
      mov cl,[ebx]                 ; move only the last byte (the number) of ebx to ecx
      shr cl, 1
      mov byte [ebx], cl           ; storing the shifted element in the node
      cmp byte [ebx+1], 0          ; check if we reached the end of X 
      je .donec
      mov esi, ebx
      mov ebx, [ebx+1]             ; ebx is now point to the next node
      jmp .mul_Xc
    
    .mul_Xc:
      mov ecx, 0
      mov cl,[ebx]                 ; move only the last byte (the number) of ebx to ecx

      shr cl, 1
      jc .carrc
      jnc .continuec
      
    .carrc:
      mov edx, 0
      mov dl, [esi]
      mov eax, 0
      mov al, 128
      or dl, al
      mov byte [esi], dl
      jmp .continuec
      
    .continuec:
      mov byte [ebx], cl           ; insert the new shifted element
      
      cmp byte [ebx+1], 0          ; check if we reached the end of X 
      je .donec
      mov esi, ebx
      mov ebx, [ebx+1]             ; ebx is now point to the next node
      jmp .mul_Xc
    .donec:
      popad
      ret

  ; -----------pop one operand from the operand stack, and push one result (num on 'one' bits)------------------
  num_bits:
    restart
    cmp byte [num_elements],1
    jl print_operator_error_msg    ; num_elements < 1

    cmp byte [num_elements],5
    je print_operand_error_msg     ; num_elements = 5 , stack overflow.
    
    inc byte [num_of_operations]  


    mov edx, [num_elements]
    dec edx
    mov ebx, [stack + 4*edx]       ; ebx = pointer to the first node in stack  
    mov eax, 0                     ; eax will be the counter of '1' bits
    
    .iterate:
      mov edx, 0
      mov dl,[ebx]                 ; move only the last byte (the number) of ebx to edx
      mov ecx, 8                   ; for the loop
      .shr_loop:
        shr dl, 1                  ; last shifted bit enters to CF flag, vacated bits are filled with zero.
        jnc .continue
        inc eax                    ; the bit is '1'
        .continue:
        loop .shr_loop, ecx
      mov ebx, [ebx+1]             ; ebx is now point to the next node
      cmp ebx, 0                   ; check if we reached the end of the list 
      jne .iterate

    free_first_operand_from_stack
    .modify:
      cmp al, 9
      jle .add_0
      jg .add_55
      .add_0:
      add al, '0'
      jmp .end
      .add_55:
      add al, 55
      jmp .end
    .end:
      mov [input], eax
      jmp push_to_stack

    

  ;----------------------------------prints the operand pointed by edx------------------------------------------
  print_operand:
    pushad
    mov ebx, 0
    .print_list:
        mov ecx, 0
        mov cl,[edx]                 ; move only the last byte (the number) of ebx to ecx
        push ecx                     ; push the number to the stack
        inc ebx
        cmp dword [edx+1], 0                   ; check if we reached the end of the list 
        je .final
        mov edx, [edx+1]             ; ebx is now point to the next node
        jmp .print_list
      .final:
        ; print the first element with no leadin zeros:
        cmp ebx, 1                   ; edx = number of nodes on the list
        je .only_one
        pop edx                      ; pop one element from the stack, store it in ebx
        cmp edx, 0
        je .dec_and_continue
        printMem edx, format_hex_no_zero
        dec ebx
      .fill:  
        cmp ebx, 1                   ; edx = number of nodes on the list
        je .last_one
        pop edx                      ; pop one element from the stack, store it in ebx
        printMem edx, format_hex     ; print this element
        dec ebx
        jmp .fill
      .dec_and_continue:
        dec ebx
        jmp .final
    .only_one:
      pop edx                      ; pop one element from the stack, store it in ebx
      printMem edx, format_hex_no_zero
      jmp .end
    .last_one:
      pop edx                      ; pop one element from the stack, store it in ebx
      printMem edx, format_hex
    .end:
      popad
      ret
 
  ;-----------------------------prints the operand pointed by edx to stderr-------------------------------------
  print_operand_err:    
    pushad
    mov ebx, 0    ; ebx = counter
    .print_list:
        mov ecx, 0
        mov cl,[edx]                 ; move only the last byte (the number) of ebx to ecx
        push ecx                     ; push the number to the stack
        inc ebx
        cmp dword [edx+1], 0                   ; check if we reached the end of the list 
        je .fill
        mov edx, [edx+1]             ; edx is now point to the next node
        jmp .print_list
      .fill:  
        cmp ebx, 0                   ; edx = number of nodes on the list
        je .end
        pop edx                      ; pop one element from the stack, store it in ebx
        mov eax, 0
        mov ecx, 4
        .shifting:
          shl dl, 1
          jc  .case_1  
          jnc .case_0
          .continue:
          loop .shifting, ecx
          jmp .printing
        
        .case_0:
          shl al, 1
          jmp .continue
        .case_1:
          shl al, 1
          inc al
          jmp .continue
        
        .printing:
        mov ecx, 4
        .shifting_back:
          shr dl, 1
          loop .shifting_back, ecx
        
        ; print them:
        call back_to_string
        mov byte [numerr], 0
        mov byte [numerr], al
        printerr numerr, 1
        
        mov eax, 0
        mov al, dl
        call back_to_string
        mov byte [numerr], 0
        mov byte [numerr], al
        printerr numerr, 1
        dec ebx
        jmp .fill

    .end:
      popad
      ret
  
  back_to_string: ; convert from [num hex value] to [char hex value]
    cmp al, 9
    jle .add_0
    jg .add_55
    .add_0:
    add al, '0'
    jmp .end
    .add_55:
    add al, 55
    jmp .end
    .end:
    ret

  ;--------------------------------copy the operand pointed by edx to ecx---------------------------------------
  copy_operand:
    .duplicate_X:
        push edx
        push 5                    ; push first argument - request 5 bytes to be allocated
        call malloc               ; now eax has the address of the new memory allocated
        add esp, 4                ; clean space created for argument
        pop edx
        mov byte [eax],0
        mov dword [eax+1],0
        mov edi, eax              ; copy pointer to eax      
        
        ; preform copy: edx => ecx
        .iterate_and_copy:
          mov ecx, 0
          mov cl,[edx]                 ; move only the last byte (the number) of ebx to ecx
          mov byte [eax], cl
          mov edx, [edx+1]             ; ebx is now point to the next node
          cmp edx, 0                   ; check if we reached the end of the list 
          jne .prepare_new_node
          je .end

        .prepare_new_node:
          mov esi, eax
          push edx
          push 5                    ; push first argument - request 5 bytes to be allocated
          call malloc               ; now eax has the address of the new memory allocated
          add esp, 4                ; clean space created for argument
          pop edx
          mov byte [eax],0
          mov dword [eax+1],0
          mov dword [esi+1],eax     ; save the address of the current node in the last 4 bytes of the new node 
          jmp .iterate_and_copy
    .end:
      mov ecx, edi
      ret
  end_main:
  ;----free all the memory in stack
  mov eax, [num_elements]         ; eax = number of elements, the counter of the loop
  cmp eax,0 
  je end_loop
  stack_loop:                     ; the main loop, going through the stack
    free_first_operand_from_stack
    dec eax
    debug9:
    cmp eax, 0
    je end_loop
    jmp stack_loop
  end_loop:             ;all memory is freed
    mov ebx, [num_of_operations]
    printMem ebx, format_hex_no_zero
    printMem endl,format_string
    mov esp,[backup_esp]
    mov ebp,[backup_ebp]
    ret


  



