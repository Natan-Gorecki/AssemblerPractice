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

section .bss    
    buffer resb 30
    initial_break resb 4
    arr_size resb 4

section	.text
   ;global _start
   global main

read_single:
    mov edi, buffer
    mov ecx, 15
    .clear:
        mov word [edi], 0
        add edi, 2
    loop .clear

    mov edi, buffer
    mov ecx, 30
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
        cmp byte [edi], ' '
        je .EOF

        inc edi
    loop .iterate

    .EOF:
    mov byte [edi], 0
    ret

convert_single_number:
    ;eax: pointer 
    ;ebx: length
    ;return eax: converted number
    mov esi, eax
    add esi, ebx
    dec esi ; esi = substring.length()-1
    
    xor edi, edi
    mov ecx, ebx
    mov ebx, 1
    xor eax, eax
    .iterate:
        xor eax, eax
        mov al, [esi]

        cmp al, 0
        je .next
        cmp al, 0xA
        je .next
        cmp al, 0xD
        je .next
        cmp al, 0x20 ; ' '
        je .next
        cmp al, 0x2D ; -
        je .change_sign
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

    mov eax, edi
    ret

    .return:
    mov eax, 0
    ret

    .change_sign:
        not edi
        add edi, 1
        jmp .next

print_signed_number:
; eax - number
    xor ebx, ebx
    push ebx ; 4 bytes on stack

    mov esi, eax
    test esi, esi
    jns .numbers
    
    .signed:
        mov byte [esp], '-'
        WRITE esp, 1
        not esi
        add esi, 1

    .numbers:
        mov edi, 1000000000
    
    .single_number:
        xor edx, edx
        mov eax, esi
        div edi

        mov esi, edx
        cmp eax, 0
        je .zero

        .print_single_number:
            add al, '0'
            mov [esp], al
            mov byte [esp+1], 1 ; information that other zeros should be written eg 100
            WRITE esp, 1

        .go_to_next:
            cmp edi, 1
            je .return

            xor edx, edx
            mov eax, edi
            mov ebx, 10
            div ebx
            mov edi, eax 
            jmp .single_number

        .zero:
            cmp byte [esp+1], 1
            je .print_single_number
            cmp edi, 1 ; last zero is mandatory
            je .print_single_number
            jmp .go_to_next

    .return:
    add esp, 4
    ret

print_reverse_array:
    mov ecx, [arr_size]
    mov edx, ecx
    dec edx

    mov eax, 4
    mul edx
    add eax, [initial_break]
    mov esi, eax

    .iterate:
        push ecx
        push esi

        cmp ecx, 1
        je .print_with_new_line

        .print_with_space:
            mov eax, [esi]    
            call print_signed_number
            
            sub esp, 1
            mov byte [esp], ' '
            WRITE esp, 1
            add esp, 1

            jmp .next
        .print_with_new_line:
            mov eax, [esi]
            call print_signed_number

            sub esp, 1
            mov byte [esp], 0xA
            WRITE esp, 1
            add esp, 1

            jmp .next
    .next:
        pop esi
        sub esi, 4
        pop ecx
    loop .iterate

    ret

;_start:
main:
    call read_single
    
    mov eax, buffer
    mov ebx, 30
    call convert_single_number
    push eax

    mov eax, SYS_BRK    
    mov ebx, 0
    int 0x80
    mov [initial_break], eax

    pop ecx
    .iterate:
        push ecx

        call read_single
        mov eax, buffer
        mov ebx, 30
        call convert_single_number
        mov [arr_size], eax

        mov ebx, 4
        mul ebx
        mov ebx, eax
        add ebx, [initial_break]
        mov eax, SYS_BRK
        int 0x80

        mov ecx, [arr_size]
        mov edx, 0
        .init_loop:
            push ecx
            push edx

            call read_single
            mov eax, buffer
            mov ebx, 30
            call convert_single_number
            mov edi, eax

            pop eax
            mov ebx, 4
            push eax
            mul ebx
            add eax, [initial_break]
            mov [eax], edi

            pop edx
            pop ecx
            inc edx
        loop .init_loop

        call print_reverse_array

        pop ecx
    loop .iterate

    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80

; nasm -f elf32 0009_ReverseArray.asm && gcc -no-pie 0009_ReverseArray.o -o 0009_ReverseArray    

; debug version
; nasm -f elf32 -g -F dwarf 0009_ReverseArray.asm && gcc -fno-builtin -no-pie 0009_ReverseArray.o -o 0009_ReverseArray
; gdb 0009_ReverseArray -tui