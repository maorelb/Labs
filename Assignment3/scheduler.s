section .text
    global sched_func
    extern printf
    extern stack_pointer
    extern stack_index
    extern N
    extern endCo
    extern result3
    extern CURR
    extern printer_CO
    global resume
    global do_resume
    extern CORS
    extern K
    extern angle
    extern distance
    extern one_handred
    extern two_devide
    extern current_drone_id
    extern sircle_radius
    extern print_empty_string
    

sched_func:
    mov ecx, [N]
    ;add ecx,3            ;ecx = N+2
    mov edi,0            ;edi = runnig index
    mov ebx,0
    mov esi,0
    
    ;inc dword [current_drone_id]
    
    loop_sched_func:
        mov ebx, [12+4*edi + CORS]
        cmp edi,[N]
        je print_board2
        cmp esi,[K]
        je print_board
        call print_empty_string
        call resume
        inc edi
        inc esi
        
        inc dword [current_drone_id]
        jmp loop_sched_func


     print_board2:
            mov edi,0
            mov dword [current_drone_id],0
            jmp loop_sched_func


     

    print_board:
        

        mov dword ebx,printer_CO
        call resume
        mov esi,0
        jmp loop_sched_func


    end_co:
     jmp endCo

    resume: ; save state of current co-routine
        pushfd
        pushad
        mov edx, [CURR]
        mov [edx+4], esp ; save current ESP
        ;jmp end_of_all


    do_resume: ; load ESP for resumed co-routine
        mov esp, [ebx+4] ;to the the stack og the co routine
        mov [CURR], ebx ; save the current of the pointer
        popad ; restore resumed co-routine state
        popfd
       
        ret ; "return" to resumed co-routine

    
