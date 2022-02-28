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
    buffer resb 250

section	.text
   ;global _start
   global main

read_line:
    mov edi, buffer
    mov ecx, 125
    .clear:
        mov word [edi], 0
        add edi, 2
    loop .clear

    mov edi, buffer
    mov ecx, 250
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

is_any_number: ; similiar to C strol
    ;eax: pointer
    ;ebx: length
    ;return eax: information if is number
    ;       ebx: substring pointer
    ;       ecx: substring size
    ;       edx: pointer to next substring, if next number exist
    push eax
    mov esi, eax
    mov ecx, ebx
    mov edx, 0
    .iterate:
        mov al, [esi]
        
        cmp al, 0
        je .maybe
        cmp al, 0xA
        je .maybe
        cmp al, 0xD
        je .maybe
        cmp al, 0x20
        je .maybe
        cmp al, 0x2D ; -
        je .next
        cmp al, '0'
        jl .no
        cmp al, '9'
        jg .no
    .next:
        mov edx, 1
        inc esi
    loop .iterate
    .maybe:
        cmp edx, 0
        je .no
        ;yes - it allows '2-2', '--2', etc
        jmp .yes 
    .no:
        mov eax, 0
        mov ebx, 0
        mov ecx, 0
        mov edx, 0
        ret
    .yes:
        push esi
        dec ecx
        cmp ecx, 0
        jle .no_next
        inc esi
        
        .next_exist:
            mov al, [esi]

            cmp al, 0
            je .no_next
            cmp al, 0xA
            je .no_next
            cmp al, 0xD
            je .no_next
            cmp al, 0x20 ; ' '
            je .next_exist_next
            cmp al, 0x2D ; -
            je .yes_next
            cmp al, '0'
            jl .no_next
            cmp al, '9'
            jg .no_next
            jmp .yes_next

            .next_exist_next:
            inc esi
        loop .next_exist
        
        .no_next:
            mov edx, 0 ;second substring not exist
            jmp .next_exist_end
        .yes_next:
            mov edx, esi ; pointer to second substring
            jmp .next_exist_end
        .next_exist_end:
        mov eax, 1 ; first substring exist
        
        pop ecx 
        pop ebx ; first substring pointer
        sub ecx, ebx ; first substring size
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

add_numbers:
; eax: pointer
; ebx: length
; return eax: sum 

    push ebx
    push eax
    xor ecx, ecx
    push ecx ; this will be sum
    
    .next_check:
        call is_any_number
        
        cmp eax, 0
        je .return 

        mov eax, ebx
        mov ebx, ecx
        push edx
        call convert_single_number
        pop edx
        add [esp], eax

        cmp edx, 0
        je .return 

        mov eax, edx
        mov ebx, [esp+8]
        mov ecx, eax
        sub ecx, [esp+4]
        sub ebx, ecx
        jmp .next_check

    .return:
    pop eax
    add esp, 8
    ret

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
    mov word [esp], 0x0A0D ;processor stores data in reverse-byte sequence
    WRITE esp, 2
    add esp, 4
    ret

;_start:
main:
    call read_line
    
    mov eax, buffer
    mov ebx, 250
    call is_any_number

    mov eax, ebx
    mov ebx, ecx
    call convert_single_number
    
    mov ecx, eax
    .iterate:
        push ecx

        call read_line
        call read_line
        
        mov eax, buffer
        mov ebx, 250
        call add_numbers
        call print_signed_number

        pop ecx
    loop .iterate

    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80

; nasm -f elf32 0006_SignedNumberAddition.asm && gcc -no-pie 0006_SignedNumberAddition.o -o 0006_SignedNumberAddition    

; debug version
; nasm -f elf32 -g -F dwarf 0006_SignedNumberAddition.asm && gcc -fno-builtin -no-pie 0006_SignedNumberAddition.o -o 0006_SignedNumberAddition
; gdb 0006_SignedNumberAddition -tui