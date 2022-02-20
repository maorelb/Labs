

global printer_func


section .rodata
    FMT2: db "Hi", 10, 0 
    result3:  db '%.2f,',0    ;; char result[] = "Hello, %s!";
    result_d: db '%d ',0
    result5:  db '%.2f,',10,0    ;; char result[] = "Hello, %s!";
    result4:  db '%d,',0    ;; char result[] = "Hello, %s!";
    endl: db 10,0
section .bss
    x_y_target1: resb 4


section .text
    extern printf
    extern stack_pointer
    extern x_y_target
    extern stack_index
    extern N
    extern x_target
    extern y_target
    extern schedular_CO
    extern resume
    extern printTarget


printer_func:

call printTarget 


loop_printer_func:
mov dword [stack_index],0
mov eax,[stack_pointer]
mov ebx,[stack_index]
;mov dword edx,[stack_pointer]
 

    loop_malloc1:
        mov eax,0
        mov eax,[stack_index]
        cmp dword eax,[N]
        je end_loop_malloc1


        ; push FMT2
        ; call printf
        ; add esp,4
        mov eax,[stack_pointer]
        mov ebx,[stack_index]
    
        push eax
        mov dword esi,[stack_index]
        inc esi
        push esi
        push result4
        call printf 
        add esp,8

        pop eax

        
        mov dword eax,[eax+ebx*4]

        push eax
        push dword[eax+4]
        push dword[eax]
        push result3
        call printf 
        add esp,12
        pop eax


        push eax
        push dword[eax+12]
        push dword[eax+8]
        push result3
        call printf 
        add esp,12
        pop eax


        push eax
        push dword[eax+20]
        push dword[eax+16]
        push result3
        call printf 
        add esp,12
        pop eax

        push eax
        push dword[eax+24]
        push result_d
        call printf 
        add esp,8
        pop eax


        push eax
        push endl
        call printf 
        add esp,4
        pop eax


        

        inc dword[stack_index]
        jmp loop_malloc1
        
        
        
        end_loop_malloc1:

        mov dword[stack_index],0

        mov ebx,schedular_CO
        call resume
        jmp printer_func