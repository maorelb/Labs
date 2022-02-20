global target_func
global init_target
global x_target
global y_target
global printTarget


 section .rodata
    FMT2: db "Hi", 10, 0 
    result3:  db '%.2f',0    ;; char result[] = "Hello, %s!";
    format_hex: db "%02X",10,0
    psik:  db ',',0    ;; char result[] = "Hello, %s!";

section .bss
    ;x_y_target: resb 4
    ;x_target: resq 1
   ; y_target: resq 1
    

section .text
    
    
    section .text
    
    extern printf
    extern stack_pointer
    extern stack_index
    extern N
    extern endCo

    extern CURR
    extern printer_CO
    extern x_target
    extern y_target
    extern check

    extern Seed
    extern temp_eax

    extern one_handred
    extern two_devide
    
    extern sixtee
    extern c
    extern schedular_CO
    extern resume
    extern endl
    
    extern malloc
    extern CORS
    extern current_drone_id



target_func:
%macro seed_to_num 0
    mov ebx,16
    mov eax,0

    %%seed_to_num1:    
    cmp ebx,0
    je %%end_seed_to_num
    mov ax, 0x2D
    and ax, word[Seed]
    jp %%end_1 ; if the num of 1 is even
    
    %%add_one:
    

    shr word[Seed],1
    mov ax, 0x8000
    add word[Seed],ax
    jmp %%end_2

    %%end_1:
    shr word[Seed],1
    
    %%end_2:
    dec ebx

    jmp %%seed_to_num1

    %%end_seed_to_num:

%endmacro

%macro make_random_from_num 1
    fild dword [Seed]
    ;printFloat 

    fild dword [one_handred]
    fmul st0,st1
    ;printFloat 


    fild dword [two_devide]
    ;printFloat

    fdiv st1,st0

    fstp  qword [c]
    fstp  qword [%1]

    
    fstp  qword [c]

    ;printFloat %1

    
%endmacro

%macro use_malloc 1
    pushad
    push %1
    call malloc
    add esp,4
    mov [temp_eax],eax
    popad
%endmacro

    seed_to_num
    make_random_from_num x_target

    seed_to_num
    make_random_from_num y_target

    mov ebx,0
    mov ebx,[current_drone_id]

    mov dword[check],1
    mov ebx, [12+4*ebx + CORS]
    call resume
    jmp target_func








printTarget: 

    push dword[x_target+4]
    push dword[x_target]
    push result3
    call printf 
    add esp,12

    
    push psik
    call printf 
    add esp,4




    push dword[y_target+4]
    push dword[y_target]
    push result3
    call printf 
    add esp,12


    push eax
    push endl
    call printf 
    add esp,4
    pop eax

    ret

init_target:


        seed_to_num
        make_random_from_num x_target



        seed_to_num
        make_random_from_num y_target

        ;call printTarget


        ret