global stack_pointer
global stack_index
global result3
global result
global CURR
global printer_CO
global endCo
global N
global T
global K
global Beta
global Dis
global Seed
global read_K
global Seed
global schedular_CO
global one_handred
global sixtee
global temp_eax
global angle
global distance
global seed_to_num
global make_random_from_num
global x_target
global y_target
global endl
global current_drone_id
global one_handred
global two_devide
global sixtee
global check_mayDestroy
global print_empty_string
global temp
global c
global print_N_structs
global my_50
global my_120
global my_0
global my_360

global temp1
global temp2
global temp3
global temp4
global sub_gamma_alpha
global sqrt
global check_if_destroy
global sircle_radius
global my_60
global my_100
global my_60_q
global radian_angle
global my_2P
global my_360_q
global my_P
global my_180
global radian_Beta
global target_CO
global my_30
global Dis
global check


global gamma

 section .rodata			; we define (global) read-only variables in .rodata section
    result:  db '%d',10,0    ;; char result[] = "Hello, %s!";
    result2:  db '%X',10,0    ;; char result[] = "Hello, %s!";
    IntFormat: db "%d",0, 0	; format string
    result3:  db '%.2f',10,0    ;; char result[] = "Hello, %s!";
    FMT2: db "Hi", 10, 0 
    format_string: db "%s",0
    format_digit: db "%d",0
    format_float: db "%.2f",0
    format_hex: db "%02X",0
    format_hex_no_zero: db "%X",0
    emptyString: db "",0
    endl: db 10,0
    printD: db "%d",10,0


    
section .bss			; we define (global) uninitialized variables in .bss section
    
    stack_pointer: resb 4
    co_routine_pointer: resb 4
    ;CORS: resb 4
    c: resq 1

    x: resq 1
    y: resq 1
    r: resq 1

    temp1: resq 1
    temp2: resq 1
    temp3: resq 1
    temp4: resq 1

    gamma: resq 1
    sub_gamma_alpha: resq 1
    sqrt: resq 1

    x_target: resq 1
    y_target: resq 1

    
    

    angle: resq 1
    
    distance: resq 1

    N: resb 4
    T: resb 4
    K: resb 4
    Beta: resd 1
    Dis: resd 1
    Seed: resd 1
    temp_eax: resd 1
    

    CODEP equ 0 ; offset of pointer to co-routine function in co-routine struct
    SPP equ 4 ; offset of pointer to co-routine stack in co-routine struct 

    
    CURR: resd 1
    SPT: resd 1 ; temporary stack pointer
    SPMAIN: resd 1 ; stack pointer of main
    STKSZ equ 16*1024 ; co-routine stack size
    sched_STK: resb STKSZ
    printer_STK: resb STKSZ
    target_STK: resb STKSZ


    global CORS             ; pointer to co-routines drones array
        CORS: resb 4 
    
 
section .data
    ;IntFormat: db '%d',0
    stack_index: dd 0
    one_handred: dd 100
    sircle_radius: dq 360
    two_devide: dd 65536
    radian_angle: dq 5.84
    radian_Beta: dq 0
    current_drone_id: dd 0
    my_50: dd 50
    my_120: dq 120
    my_100: dq 100
    my_60: dd 60
    my_60_q: dq 60
    my_0: dd 0
    my_360: dd 360
    my_180: dd 180
    my_360_q: dq 0
    my_30: dq 30.00
    sixtee: dd 60
    check: dd 0
    my_2P: dq   6.28318530718
    my_P: dq  3.14159265359
    check_mayDestroy: dd 0
    ;HexaFormat: db "%x",0
    check_if_destroy: dd 0

    temp: dq 20


    ; structure for schedular co-routine
  schedular_CO: dd sched_func
                dd sched_STK+STKSZ
  ; structure for printer co-routine
  printer_CO: dd printer_func
              dd printer_STK+STKSZ
  ; structure for target co-routine
  target_CO:  dd target_func
              dd target_STK+STKSZ

   
section .text
align 16
     global main
     global myCalc
     extern printf
     extern sscanf
     extern malloc 
     extern drone_func
     extern sched_func
     extern printer_func
     extern target_func
     extern resume
     extern do_resume
     extern init_target    
;-------------------------------MAIN------------------------------
main:

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

%macro printFloat 1
    pushad ; error 2 maker

    push dword[%1+4]
    push dword[%1]
    push result3
    call printf 
    add esp,12

    popad
%endmacro


%macro angleToRadian 1
    pushad ; error 2 maker

    fild dword [Seed]


    fild dword [one_handred]
    fmul st0,st1



    fild dword [two_devide]


    fdiv st1,st0

    fstp  qword [c]
    fstp  qword [%1]

    
    fstp  qword [c]

    popad
%endmacro


%macro printDroneStack 0
    mov eax,[stack_pointer]
    mov ebx,[stack_index]
    ;mov dword edx,[stack_pointer]
    

    %%loop_malloc1:
        mov eax,0
        mov eax,[stack_index]
        cmp dword eax,[N]
        je %%end_loop_malloc1

        mov eax,[stack_pointer]
        mov ebx,[stack_index]
        
        mov eax,dword[eax+ebx*4]

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


        

        inc dword[stack_index]
        jmp %%loop_malloc1
        
        
        
        %%end_loop_malloc1:

        mov dword[stack_index],0
    

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



%macro make_random_from_num_360  1
   fild dword [Seed]
    ;printFloat 

    fild dword [sircle_radius]
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


%macro printMem 2
    pushad              ; print memoty location to stdout
    push %1 
    push %2 
    call printf
    add esp,8           ; clean up stack after call (4 for each pointer, 4 + 4 = 8).
    popad
%endmacro

%macro printlMem 2
    pushad              ; print memoty location to stdout
    push %1
    push %2 
    call printf
    add esp,8           ; clean up stack after call (4 for each pointer, 4 + 4 = 8).
    popad
    printMem endl, format_string
%endmacro

mov ebp, esp 
mov ecx, [esp+4] ; the argc
mov edx,[esp+8] ; start the reguler parameters

;push ebp NO


;pushad
mov dword[Seed],0
   
read_N:
    pushad
    push N
    push IntFormat
    mov dword eax,[edx+4]
    push eax
    call sscanf
    add esp,12
    mov eax,0
    popad

    ;     pushad
    ; push dword[N]
    ; push printD
    ; call printf
    ; add esp,8
    ; popad

    
read_T:
    pushad
    push T
    push IntFormat
    mov dword eax,[edx+8]
    push eax
    call sscanf
    add esp,12
    mov eax,0
    popad

    ;     pushad
    ; push dword[T]
    ; push printD
    ; call printf
    ; add esp,8
    ; popad

read_K:
    pushad
    push K
    push IntFormat
    mov dword eax,[edx+12]
    push eax
    call sscanf
    add esp,12
    mov eax,0
    popad

    ; pushad
    ; push dword[K]
    ; push printD
    ; call printf
    ; add esp,8
    ; popad

read_Beta:
    pushad
    push Beta
    push IntFormat
    mov dword eax,[edx+16]
    push eax
    call sscanf
    add esp,12
    mov eax,0
    popad

    ;     pushad
    ; push dword[Beta]
    ; push printD
    ; call printf
    ; add esp,8
    ; popad

read_Dis:
    pushad
    push Dis
    push IntFormat
    mov dword eax,[edx+20]
    push eax
    call sscanf
    add esp,12
    mov eax,0
    popad

    ;         pushad
    ; push dword[Dis]
    ; push printD
    ; call printf
    ; add esp,8
    ; popad



read_Seed:
    pushad
    push Seed
    push IntFormat
    mov dword eax,[edx+24]
    push eax
    call sscanf
    add esp,12
    mov eax,0
    popad

    ;         pushad
    ; push dword[Seed]
    ; push printD
    ; call printf
    ; add esp,8
    ; popad
    

;------INIT_DRONE_RANDOM--------
;mov dword [Seed],0x3AAB
;mov dword [N],5
;mov dword [T],3
;mov dword [K],10
;mov dword [Beta],15


call init_target


make_stack_drones:


    mov edx,0
    mov edx,16


    pushad
    push edx
    call malloc
    add esp,4
    mov dword[stack_pointer],eax
    popad
   
    ;------MAKE_DRONE_RANDOM--------
    loop_malloc:
        mov eax,0
        mov eax,[stack_index]
        cmp dword eax,[N]
        je end_loop_malloc


        seed_to_num
        make_random_from_num x

        seed_to_num
        make_random_from_num y

        seed_to_num
        make_random_from_num_360 r


        pushad
        push 28          ;make the first head pointer
        call malloc        
        add esp,4
        

        mov esi,0
        mov edi,0
        mov dword esi,[x]
        mov dword edi,[x+4]
        mov dword[eax],esi
        mov dword[eax+4],edi

        mov esi,0
        mov edi,0
        mov dword esi,[y]
        mov dword edi,[y+4]
        mov dword[eax+8],esi
        mov dword[eax+12],edi

        mov esi,0
        mov edi,0
        mov dword esi,[r]
        mov dword edi,[r+4]
        mov dword[eax+16],esi
        mov dword[eax+20],edi

        mov edi,0
        mov dword[eax+24],edi



        mov ebx,[stack_index]
        mov edx,0
        mov dword edx,[stack_pointer]
        mov dword[edx+ebx*4],eax

        popad

        inc dword[stack_index]
        jmp loop_malloc
        
        
        
        end_loop_malloc:

        mov dword [stack_index],0
        ;printDroneStack

        
        end_stack_drones:

initilize:    

    mov dword edx,[N]
    add edx,3
    pushad
    push edx
    call malloc
    add esp,4
    mov dword[co_routine_pointer],eax
    popad

init_drones_CORS_array:
    
    mov ebx,[N]
    shl ebx,2  ; check! why               
    add ebx,3                 
    use_malloc ebx                     ; total space needed = 4*N +3
    mov esi, [temp_eax]
    mov [CORS],esi   ; esi is      
    mov dword [CORS],schedular_CO      ;cores[0] = schedular_CO  
    mov dword [CORS+4],printer_CO      ;cores[1] = printer_CO
    mov dword [CORS+8],target_CO        ;cores[2] = target_CO  

    

;----------creating N structures for the N drones and save into cores array-----
    mov ecx,[N]
    mov eax,drone_func
    mov edx,0
  
create_N_structs:
    use_malloc 8                    ;allocate space for struct    
    mov esi,[temp_eax]           ; esi = pointer to new struct 
    mov dword [esi],drone_func            ;struct -> func = drone_func
    use_malloc STKSZ              ;allocate space for struct stack
    mov edi,[temp_eax]
    mov dword [esi+4],edi                 ; struct -> stk = new stack 
    mov [CORS +12 + 4*edx],esi      ; cores[j] = strct
    inc edx
    loop create_N_structs,ecx


;---------------init co-routines ----------

init_co_routines:
    mov ecx, [N]
    add ecx,3            ;ecx = N+2
    mov edi,0            ;edi = runnig index
    mov ebx,0

initCo:
    cmp edi,ecx
    je end_initCo
    ;mov ebp,esp
    ;mov ebx, [ebp+8]; get co-routine ID number
    mov ebx, [4*edi + CORS]; get pointer to COi struct
    mov eax, [ebx+CODEP]; get pointer to COi function
    mov [SPT], esp; save ESP value
    mov esp, [ebx+SPP]; get pointer to COi stack
    push eax; push initial “return” address
    pushfd; push flags
    pushad; push all other registers
    mov [ebx+SPP], esp   ; save new SPi value (after all the pushes)
    mov esp, [SPT]      ;restore ESP valu

    ;ret

    inc edi
    jmp initCo
end_initCo:
         


startCo:
    pushad ; save registers of main ()
    mov [SPMAIN], esp ; save ESP of main ()
    mov ebx, schedular_CO ; gets ID of a scheduler co-routine

    jmp do_resume ; resume a scheduler co-routine



 endCo:
    mov esp, [SPMAIN] ; restore ESP of main()
    popad ; restore registers of main() important!!!


    
end_of_all:
    
    ;popad
    ;mov esp, ebp	
    ;pop ebp
    mov esp,ebp
    ret
;-------------------------------START MY CALC------------------------------
   
    
    

; print_N_structs:
;    mov esi,0
;    mov ecx,[N]
;    add ecx,3
;    p:
;       mov ebx, [4*esi + CORS]; get pointer to COi struct
;       printlMem dword [ebx+CODEP],format_hex
;       printlMem dword [ebx+SPP],format_hex
;       printMem endl,format_string
;       inc esi
;       loop p,ecx
;     ret

print_empty_string:

   mov edx,0
   mov ecx,[N]
   add ecx,3
   p:
      mov ebx, [4*edx + CORS]; get pointer to COi struct
    ;   printlMem dword emptyString,format_string
    ;   printlMem dword emptyString,format_string
    ;   printMem emptyString,format_string
      inc edx
      loop p,ecx
    
    ret
