SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
SYS_BRK equ 45
STDIN equ 0
STDOUT equ 1

%macro WRITE 2
    mov eax, 4
    mov ebx, 1
    lea ecx, [%1]
    mov edx, %2
    int 80h
%endmacro

section	.text
   ;global _start
   global main

read_line:
    ;eax: buffer
    ;ebx: size
    push eax
    push ebx

    mov edi, eax
    mov ecx, ebx
    .clear:
        mov byte [edi], 0
        inc edi
    loop .clear

    mov edi, eax
    mov ecx, ebx

    .iterate:
        push ecx
        
        mov eax, SYS_READ
        mov ebx, STDIN
        mov ecx, edi
        mov edx, 1
        int 80h

        pop ecx

        cmp eax, 0 ; EOF
        je .EOF
        cmp byte [edi], 0xA
        je .EOF

        inc edi
    loop .iterate

    .EOF:
    pop ebx
    pop eax
    ret

convert_number:
    ;eax: buffer
    ;ebx: size
    ;return eax: number1
    ;return ebx: number2
    mov esi, eax ; iterate on buffer through esi 
    add esi, ebx
    dec esi

    xor edi, edi ; store result in edi
    mov ecx, ebx
    mov ebx, 1 ; 1, 10, 100
    xor eax, eax

    sub esp, 8
    mov [esp], eax
    mov [esp+4], eax

    .iterate:
        mov al, [esi]
        
        cmp al, 0
        je .next
        cmp al, 0xA
        je .next
        cmp al, 0xD
        je .next
        cmp al, 0x20 ; second number
        je .second_number
        cmp al, '0'
        jl .return
        cmp al, '9'
        jg .return

        sub al, '0'
        mul ebx
        add edi, eax

        mov eax, ebx
        mov ebx, 10
        mul ebx
        mov ebx, eax
        
    .next:
        dec esi
    loop .iterate

    .return:
        mov eax, edi
        mov [esp], eax

        mov eax, [esp]
        mov ebx, [esp+4]
        add esp, 8
        ret

    .second_number:
        cmp dword [esp+4], 0x0
        jne .next

        mov eax, edi
        mov [esp+4], eax
        xor edi, edi
        mov ebx, 1

        jmp .next

gcd:
    ; eax - number1
    ; ebx - number2
    ; return gcd in eax
    .while:
        cmp al, bl
        jl .bl_greater
        jg .al_greater
        ret
    .al_greater:
        sub al, bl
        jmp .while
    .bl_greater:
        sub bl, al
        jmp .while

lcm:
    ; eax - number1
    ; ebx - number2
    ; return lcm in eax
    push eax
    push ebx

    call gcd

    mov ecx, eax
    pop eax
    pop ebx

    mul ebx    
    xor edx, edx
    div ecx
    
    ret
    
print_lcm:
    ; eax - lcm to print    
    push eax
    sub esp, 3 ; ?

    xor edx, edx
    mov ebx, 100
    div ebx
    add eax, '0'
    mov [esp], al

    mov eax, edx
    xor edx, edx
    mov ebx, 10
    div ebx
    add al, '0'
    add dl, '0'
    mov [esp+1], al
    mov [esp+2], dl

    cmp byte [esp], '0'
    je .tens
    WRITE esp, 1

    .tens:
        cmp byte [esp+1], '0'
        je .zero_tens
        WRITE esp+1, 1
        jmp .unities
    
    .zero_tens:
        cmp byte [esp], '0'
        je .unities
        WRITE esp+1, 1

    .unities:
        WRITE esp+2, 1
    
    mov word [esp], 0x0D0A
    WRITE esp, 2
    
    add esp, 3
    pop eax
    ret

;_start:
main:
    mov eax, SYS_BRK
    mov ebx, 0
    int 0x80
    push eax
    
    mov ebx, eax
    mov eax, SYS_BRK
    add ebx, 12
    int 0x80
    
    mov eax, [esp]
    mov ebx, 10
    call read_line

    mov eax, [esp]
    mov ebx, 10
    call convert_number
    mov ecx, eax

    .iterate:
        push ecx

        mov eax, [esp+4]
        mov ebx, 10
        call read_line

        mov eax, [esp+4]
        mov ebx, 10
        call convert_number
        call lcm
        call print_lcm

        pop ecx
    loop .iterate

    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80

; nasm -f elf32 0005_LCM_GCD_with_brk.asm && gcc -no-pie 0005_LCM_GCD_with_brk.o -o 0005_LCM_GCD_with_brk    

; debug version
; nasm -f elf32 -g -F dwarf 0005_LCM_GCD_with_brk.asm && gcc -fno-builtin -no-pie 0005_LCM_GCD_with_brk.o -o 0005_LCM_GCD_with_brk
; gdb 0005_LCM_GCD_with_brk -tui