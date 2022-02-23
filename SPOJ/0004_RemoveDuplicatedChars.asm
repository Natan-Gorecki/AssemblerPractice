SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .bss    
    buffer resb 240 ; 1 <= count <= 200
    number resb 1 ; 1 <= number1 <= 50

section	.text
   ;global _start
   global main


read_line:
    mov edi, buffer
    mov ecx, 60
    .clear:
        mov dword [edi], 0
        add edi, 4
    loop .clear

    mov edi, buffer
    mov ecx, 240
    .array_size:
        push ecx;

        mov eax, SYS_READ ; sys_write
        mov ebx, STDIN ; stdout
        mov ecx, edi
        mov edx, 1
        int 80h

        pop ecx;
        
        cmp eax, 0 ; EOF
        je .EOF
        cmp byte [edi], 0xA
        je .EOF

        inc edi
    loop .array_size
    
    .EOF:
    mov byte [edi], 0xA
    ret

convert_number:
    mov esi, buffer ; iterate on buffer through esi
    add esi, 9
    xor edi, edi ; store result in edi
    mov ecx, 10
    mov ebx, 1 ; 1, 10, 100...

    .array_size:
        cmp byte [esi], 0
        je .next
        cmp byte [esi], 0xA
        je .next
        cmp byte [esi], 0xD
        je .next
        cmp byte [esi], '0'
        jl .return 
        cmp byte [esi], '9'
        jg .return

        xor eax, eax
        mov al, [esi]
        sub eax, '0'
        
        mul ebx
        add edi, eax
        
        mov eax, ebx
        mov ebx, 10
        mul ebx
        mov ebx, eax

    .next:
        dec esi
    loop .array_size

    .return:
    mov [number], edi
    ret

printf_number:
; eax - number
    mov esi, eax
    xor edx, edx
    sub esp, 0x3
    
    mov ebx, 100
    div ebx
    add eax, '0'
    mov byte [esp], al

    mov eax, edx
    xor edx, edx
    mov ebx, 10
    div ebx
    add eax, '0'
    add edx, '0'
    mov byte [esp+1], al
    mov byte [esp+2], dl

    hundreds:
        cmp byte [esp], '0'
        je .tens
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        lea ecx, [esp]
        mov edx, 1
        int 0x80

    .tens:
        cmp byte [esp+1], '0'
        je .zero_tens

        mov eax, SYS_WRITE
        mov ebx, STDOUT
        lea ecx, [esp+1]
        mov edx, 1
        int 0x80
        jmp .unities

        .zero_tens:
        cmp byte [esp], '0'
        je .unities

        mov eax, SYS_WRITE
        mov ebx, STDOUT
        lea ecx, [esp+1]
        mov edx, 1
        int 0x80

    .unities:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        lea ecx, [esp+2]
        mov edx, 1
        int 0x80

    add esp, 0x3
    mov eax, esi
    ret

printf_duplicated_char:
; eax - duplicated char
; ebx - count
    push eax
    push ebx

    cmp ebx, 2
    jg .char_and_count
    
    cmp ebx, 1
    jg .char_and_char

    cmp ebx, 0
    jg .char_only

    jmp .exit

    .char_only:
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        lea ecx, [esp + 4]
        mov edx, 1
        int 0x80

        jmp .exit

    .char_and_count:    
        mov eax, SYS_WRITE
        mov ebx, STDOUT
        lea ecx, [esp + 4]
        mov edx, 1
        int 0x80

        mov eax, [esp]
        call printf_number

        jmp .exit

    .char_and_char:
        sub esp, 2
        mov byte [esp], al
        mov byte [esp+1], al

        mov eax, SYS_WRITE
        mov ebx, STDOUT
        mov ecx, esp
        mov edx, 2
        int 0x80

        add esp, 2
        jmp .exit

    .exit:
        pop eax
        pop ebx
        ret
remove_duplicated_chars:
    push ebp
    mov ebp, esp
    sub esp, 3
    
    mov byte [ebp-1], 0 ; current_char
    mov byte [ebp-2], 0 ; count
    mov byte [ebp-3], 0xA ; new_line '\n'
    
    mov esi, buffer
    mov ecx, 240
     
    .buffer_loop:
        cmp byte [esi], 0
        je .exit
        cmp byte [esi], 0xA
        je .exit
        cmp byte [esi], 0xD
        je .exit
        
        mov al, [ebp-1]
        cmp [esi], al
        je .same_char

        .different_char:
            push esi

            mov al, [ebp-1]
            mov bl, [ebp-2]
            call printf_duplicated_char

            pop esi

            mov al, [esi]
            mov [ebp-1], al
            mov byte [ebp-2], 1

            jmp .next

        .same_char:
            inc byte [ebp-2]
            jmp .next

        .next:
            inc esi
    loop .buffer_loop

    .exit:
        mov byte [esp], 0xA

        push esi

        mov al, [ebp-1]
        mov bl, [ebp-2]
        call printf_duplicated_char

        pop esi

        mov eax, SYS_WRITE
        mov ebx, STDOUT
        lea ecx, [ebp-3]
        mov edx, 1
        int 0x80

        add esp, 3
        pop ebp
        ret

;_start:
main:
    call read_line
    call convert_number
    mov ecx, [number]
    
    .iterate:
        push ecx

        call read_line
        call remove_duplicated_chars

        pop ecx
    loop .iterate
    
    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80


; nasm -f elf32 0004_RemoveDuplicatedChars.asm && gcc -no-pie 0004_RemoveDuplicatedChars.o -o 0004_RemoveDuplicatedChars

; debug version
; nasm -f elf32 -g -F dwarf 0004_RemoveDuplicatedChars.asm && gcc -fno-builtin -no-pie 0004_RemoveDuplicatedChars.o -o 0004_RemoveDuplicatedChars
; gdb 0004_RemoveDuplicatedChars -tui