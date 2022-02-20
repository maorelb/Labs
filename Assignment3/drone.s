global drone_func


section .rodata
    FMT2: db "Hi", 10, 0 
    winner: db "Drone id %d: I am a winner",10,0
    result3:  db '%.2f ',0    ; char result[] = "Hello, %s!";
    result4:  db '%d, ',0    ; char result[] = "Hello, %s!";
    result5:  db '%.2f ',10,0    ; char result[] = "Hello, %s!";
    result6: db '%d ',0
    printD: db "%d",10,0
    








section .text

    extern printf

    extern N
    extern Seed
    
    extern schedular_CO
    extern resume
    extern angle
    extern distance
    extern one_handred
    extern two_devide
    extern c
    extern endl
    extern my_50
    extern my_120
    extern current_drone_id
    extern stack_pointer
    extern check_mayDestroy
    extern temp
    extern x_target
    extern y_target
    extern temp1
    extern temp2
    extern temp3
    extern Dis
    extern temp4
    extern sub_gamma_alpha
    extern beta ; check qword
    extern sqrt
    extern K
    extern gamma
    extern Beta
    extern sircle_radius
    extern check_if_destroy
    extern my_0
    extern my_60 
    extern my_100
    extern my_60_q
    extern T
    extern radian_angle
    extern my_2P
    extern my_P
    extern my_360_q
    extern my_180
    extern radian_Beta
    extern target_CO
    extern my_30
    extern check
    
drone_func:

; cmp dword[check],1
; je go_back
%macro rotate_if_tooMuch_360 3
    fld qword[sircle_radius]
    fld qword [%1]
    fsubp st1, st0
    fstp qword [%2]

%endmacro

%macro rotate_if_tooMuch_100 3
    fld qword[one_handred]
    fld qword [%1]
    fsubp st1, st0
    fstp qword [%2]

%endmacro

%macro printQ 1
    pushad
    push dword[%1+4]
    push dword[%1]
    push result3
    call printf 
    add esp,12

    push eax
    push endl
    call printf 
    add esp,4
    pop eax
    popad

%endmacro

%macro printDrone 0
        mov ebx,0
        mov ebx,[current_drone_id]

        mov eax,0
        mov eax,[stack_pointer]

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
        push result6
        call printf 
        add esp,8
        pop eax

        push eax
        push endl
        call printf 
        add esp,4
        pop eax



    

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

%macro make_random_from_num_120 1
    fild dword [Seed]
    ;printFloat 

    fild dword [my_120]
    fmul st0,st1
    ;printFloat 


    fild dword [two_devide]
    ;printFloat

    fdiv st1,st0

    fstp  qword [c]
    fstp  qword [%1]

    
    fstp  qword [c]

    fld qword[angle]
    fild qword [my_60_q]
    fsubp
    fstp qword [angle]

    ;printFloat %1

    
%endmacro

%macro make_random_from_num_50 1
    fild dword [Seed]
    ;printFloat 

    fild dword [my_50]
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


%macro angleToRadian 0
pushad
    mov ebx,0
    mov ebx,[current_drone_id]

    mov eax,0
    mov eax,[stack_pointer]

    mov dword eax,[eax+ebx*4]

    fld qword [eax+16]
    fld qword [my_P]
    fmul st0,st1

    fstp  qword [radian_angle]
    fstp  qword [c]


    fld qword [radian_angle]
    fild qword [my_180]
    
    
    ; ;printFloat

    fdiv st1,st0

    fstp  qword [c]
    fstp  qword [radian_angle]

    



    ; push dword[radian_angle+4]
    ; push dword[radian_angle]
    ; push result3
    ; call printf 
    ; add esp,12

    ; push eax
    ; push endl
    ; call printf 
    ; add esp,4
    ; pop eax

popad
    
%endmacro


%macro make_Radian_Beta 0
    pushad
  

    fild dword [Beta]
    fld qword [my_P]
    fmul st0,st1

    fstp  qword [radian_Beta]
    fstp  qword [c]


    fld qword [radian_Beta]
    fild qword [my_180]
    
    
    ; ;printFloat

    fdiv st1,st0

    fstp  qword [c]
    fstp  qword [radian_Beta]

    



    ; push dword[radian_Beta+4]
    ; push dword[radian_Beta]
    ; push result3
    ; call printf 
    ; add esp,12

    ; push eax
    ; push endl
    ; call printf 
    ; add esp,4
    ; pop eax

    popad
    
%endmacro



start_func:
    ;printQ x_target
    ;printQ y_target
    seed_to_num
    make_random_from_num_120 angle ; make minus too
    
    

    seed_to_num
    make_random_from_num_50 distance


;call printDisanceAngle

  
calculate_new_drone_position:


   
    ;printDrone

    mov ebx,0
    mov ebx,[current_drone_id]

    mov eax,0
    mov eax,[stack_pointer]

    mov dword eax,[eax+ebx*4]


    

;------------add angle----------
    fld qword[eax+16]
    fld qword [angle]
    faddp
    fstp qword [eax+16]

    

    ; fld qword[eax+16]
    
    ; fsub qword [my_60]
    ; fstp qword[eax+16]

;-------check if in range----------





    fild dword [my_0]
    fld qword[eax+16]
    fcomi 
	ja next5



    fld qword[eax+16]
    fild qword [sircle_radius]
    faddp
    fstp qword [eax+16]

    next5:
        fstp qword [c]
        fstp qword [c]	

        
        fild qword [sircle_radius]
        fld qword[eax+16]
        fcomi
        jb next6

        fld qword[eax+16]
        fild qword [sircle_radius]
        fsubp
        fstp qword [eax+16]

    next6:
    fstp qword [c]
    fstp qword [c]	



angleToRadian
;-----------add dis---------

; ;------------add in x--------
	fld qword[radian_angle]
	fcos 
	fmul qword[distance]
	fadd qword[eax]
	fstp qword[eax]
;-------check if in range----------



    fild dword [my_0]
    fld qword[eax]
    fcomi 
	ja next1



    fld qword[eax]
    fild qword [my_100]
    faddp
    fstp qword [eax]

    next1:
        fstp qword [c]
        fstp qword [c]	

        
        fild qword [my_100]
        fld qword[eax]
        fcomi
        jb next2

        fld qword[eax]
        fild qword [my_100]
        fsubp
        fstp qword [eax]

    next2:
    fstp qword [c]
    fstp qword [c]	

    

     

; ;------------add in y--------

; ;------------add in x--------
	fld qword[radian_angle]
	fsin 
	fmul qword[distance]
	fadd qword[eax+8]
	fstp qword[eax+8]
;-------check if in range----------



    fild dword [my_0]
    fld qword[eax+8]
    fcomi 
	ja next3



    fld qword[eax+8]
    fild qword [my_100]
    faddp
    fstp qword [eax+8]

    next3:
        fstp qword [c]
        fstp qword [c]	

        
        fild qword [my_100]
        fld qword[eax+8]
        fcomi
        jb next4

        fld qword[eax+8]
        fild qword [my_100]
        fsubp
        fstp qword [eax+8]

    next4:
    fstp qword [c]
    fstp qword [c]	



;------------check if destroy--------
distroy:

    call mayDestroy
;---------add points-----------  
    mov ebx,0
    mov ebx,[current_drone_id]

    mov eax,0
    mov eax,[stack_pointer]
    mov dword eax,[eax+ebx*4]  
    ;inc dword[eax+24]
    mov ecx,[T]
    cmp dword[eax+24],ecx
    jne not_mayDestroy
    
    pushad
    mov ebx,[current_drone_id]
    inc ebx
    push ebx
    push winner
    call printf
    add esp,8
    popad
 
    mov eax, 1                
	mov ebx, 0 
	int 0x80

    not_mayDestroy:


end_all:


mov ebx,schedular_CO
call resume
jmp drone_func



;---------FUNCTIONS----------
printDisanceAngle:  
    pushad      
    push dword[distance+4]
    push dword[distance]
    push result3
    call printf 
    add esp,12


    push dword[angle+4]
    push dword[angle]
    push result3
    call printf 
    add esp,12

    push eax
    push endl
    call printf 
    add esp,4
    pop eax
    popad
    
    ret







mayDestroy:
    mov ebx,0
    mov ebx,[current_drone_id]

    mov eax,0
    mov eax,[stack_pointer]

    mov dword eax,[eax+ebx*4]

;-------x1-x2------
	fld qword [x_target] ;xtarget-x
	fld qword[eax]
	fsubp st1, st0
	fstp qword[temp1]
    ;printQ temp1




;-------y1-y2------
    fld qword [y_target]
	fld qword[eax+8]
	fsubp st1, st0
	fstp qword[temp2]

    ;printQ temp2

;-------calculate gamma------ 

    fld qword [temp2]
	fld qword[temp1]
	fpatan
	fstp qword[gamma]
    ; printQ radian_angle
    ; printQ gamma

; ;-------abs alpha - gamma ------ 

    fld qword [radian_angle]
	fld qword[gamma]
	fsubp st1, st0
    ;fabs
    fstp qword[sub_gamma_alpha]

;---------3.14<sub_gamma_alpha
    fld qword[my_P]
	fld qword[sub_gamma_alpha]
    fcomi
    jb next_sub_gamma_alpha


    fld qword[sub_gamma_alpha]
	fld qword[my_2P]
    fsubp st1, st0
    fstp qword[sub_gamma_alpha]

    

next_sub_gamma_alpha:
fstp qword [c]
    fstp qword [c]

; pushad
; mov ebx,[current_drone_id]
; push ebx
; push printD
; call printf
; add esp,8
; popad

;printQ radian_angle
    ;printQ gamma
   
make_Radian_Beta

;printQ sub_gamma_alpha
;printQ radian_Beta


;-------sub_gamma_alpha< beta ------
    
    
    fld qword[sub_gamma_alpha]
	fabs
    fld qword [radian_Beta]
    fcomi 

    jb next7
    inc dword[check_if_destroy]

 next7:
    fstp qword [c]
    fstp qword [c]	




; ;-------CHECK NEXT ARG---------

;-------x1-x2------
	fld qword [x_target]
	fld qword[eax]
	fsubp st1, st0
	fstp qword[temp1]

    ;printQ temp1

;-------y1-y2------
    fld qword [y_target]
	fld qword[eax+8]
	fsubp st1, st0
	fstp qword[temp2]

    ;printQ temp2

;-------sqrt((y2-y1)^2+(x2-x1)^2)------
	fld qword[temp1]
	fmul st0,st0
	fld qword[temp2]
	fmul st0,st0
	faddp
	fsqrt
	fstp qword[sqrt]

    ;printQ sqrt

    ;pushad
    
    ; push dword [Dis]
    ; push printD
    ; call printf
    ; add esp,8
    ; popad

;-------sqrt((y2-y1)^2+(x2-x1)^2)  < d  ------
    ;printQ distance
    fld qword[sqrt]
	fabs
    fild dword [Dis]
    fcomi
    jb next8
    inc dword[check_if_destroy]
    


next8:
    fstp qword [c]
    fstp qword [c]	
    cmp dword[check_if_destroy],2
    jne next9


    mov eax,[stack_pointer]
    mov dword eax,[eax+ebx*4] 
    inc dword[eax+24]

    ; pushad
    ; mov dword ebx,target_CO
    ; call resume
    ; popad
    
    
    seed_to_num
    make_random_from_num x_target

    seed_to_num
    make_random_from_num y_target

    ; pushad
    ; push dword [check_if_destroy]
    ; push result4
    ; call printf
    ; add esp,8
    ; popad

next9:
    mov dword[check_if_destroy],0
    ret
