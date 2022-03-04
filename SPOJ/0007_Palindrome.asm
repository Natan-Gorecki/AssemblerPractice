SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
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
    number resb 20
    reverse_number resb 20

section	.text
   ;global _start
   global main

read_line:
    mov edi, number
    mov ecx, 10
    .clear:
        mov word [edi], 0
        add edi, 2
    loop .clear

    mov edi, number
    mov ecx, 10
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

is_palindrome:
    mov edi, number
    .find_last_index:
        cmp byte [edi], 0
        je .found
        cmp byte [edi], 0xD
        je .found
        cmp byte [edi], 0xA
        je .found
        
        inc edi
        jmp .find_last_index
    .found:
        dec edi ; edi = number[strlen(number)-1]

    mov esi, number
    
    .while_loop:
        cmp esi, edi
        jge .yes_return
        
        mov al, [esi]
        mov bl, [edi]
        cmp al, bl
        jne .no_return

        inc esi    
        dec edi
        jmp .while_loop

    .yes_return:
    mov eax, 1
    ret
    .no_return:
    mov eax, 0
    ret

convert_to_reverse:
    mov esi, number
    mov ecx, 0
    .find_last_index:
        cmp byte [esi], 0
        je .found
        cmp byte [esi], 0xD
        je .found
        cmp byte [esi], 0xA
        je .found
        
        inc esi
        inc ecx
        jmp .find_last_index
    .found:
        dec esi ; esi = number[strlen(number)-1]
    mov edi, reverse_number

    .iterate:
        mov al, [esi]
        mov [edi], al

        dec esi
        inc edi
    loop .iterate
    ret

replace_number_with_sum:
    mov eax, number
    mov ebx, 20
    call convert_single_number
    push eax

    mov eax, reverse_number
    mov ebx, 20
    call convert_single_number

    pop ebx
    add eax, ebx

    mov esi, reverse_number
    mov ecx, 5
    .clear:
        mov dword [esi], 0
        add esi, 4
    loop .clear

    call store_sum_as_text
    ret

store_sum_as_text:
    ; eax - number
    mov esi, number
    sub esp, 1
    push esi

    mov ecx, 5
    .clear:
        mov dword [esi], 0
        add esi, 4
    loop .clear

    mov esi, eax
    mov edi, 1000000000
    
    .single_number:
        xor edx, edx
        mov eax, esi
        div edi

        mov esi, edx
        cmp eax, 0
        je .zero

        .print_single_number:
            add eax, '0'
            mov ebx, [esp]
            mov [ebx], eax
            mov byte [esp+4], 1 ; information that other zeros should be written eg 100
            inc dword [esp]

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
            cmp byte [esp+4], 1
            je .print_single_number
            cmp edi, 1 ; last zero is mandatory
            je .print_single_number
            jmp .go_to_next

    .return:
    add esp, 5
    ret

print_result:
    ;eax: pointer
    ;ebx: count
    mov esi, eax
    mov ecx, 20
    xor eax, eax
    push eax
    
    add bl, '0'
    mov byte [esp+1], bl ; count <= 10
    mov byte [esp+2], 0xD
    mov byte [esp+3], 0xA

    .iterate:
        mov al, [esi]
        cmp al, 0
        je .return
        cmp al, 0xA
        je .return
        cmp al, 0xD
        je .return
        cmp al, '0'
        jl .return
        cmp al, '9'
        jg .return

        mov [esp], al
        WRITE esp, 1
        inc esi
    loop .iterate
    
    .return:
    mov byte [esp], ' '
    WRITE esp, 4
    pop eax
    ret

single_test:
    mov esi, number
    mov edi, reverse_number
    mov ecx, 10
    .clear:
        mov word [esi], 0
        mov word [edi], 0
        add esi, 2
        add edi, 2
    loop .clear
    
    xor eax, eax
    push eax
    call read_line
    
    .palindrome_loop:
        call is_palindrome
        cmp eax, 1
        je .return 
    
        call convert_to_reverse
        call replace_number_with_sum
        inc dword [esp]

        jmp .palindrome_loop

    .return:
        mov eax, number
        mov ebx, [esp]
        call print_result
        pop eax
        ret

;_start:
main:
    call read_line

    mov eax, number
    mov ebx, 20
    call convert_single_number
    
    mov ecx, eax
    .iterate:
        push ecx
        call single_test
        pop ecx
    loop .iterate

    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80

; nasm -f elf32 0007_Palindrome.asm && gcc -no-pie 0007_Palindrome.o -o 0007_Palindrome    

; debug version
; nasm -f elf32 -g -F dwarf 0007_Palindrome.asm && gcc -fno-builtin -no-pie 0007_Palindrome.o -o 0007_Palindrome
; gdb 0007_Palindrome -tui