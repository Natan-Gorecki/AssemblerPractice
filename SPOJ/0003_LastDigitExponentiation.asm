SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .bss    
    buffer resb 30
    number1 resb 4
    number2 resb 4


section	.text
   ;global _start
   global main


read_line:
    mov edi, buffer
    mov ecx, 15
    .clear:
        mov word [edi], 0
        add edi, 2
    loop .clear

    mov edi, buffer
    mov ecx, 30
    .array_size:
        push ecx;

        mov eax, SYS_READ ; sys_write
        mov ebx, STDIN ; stdout
        mov ecx, edi
        mov edx, 1
        int 80h

        pop ecx;
        
        cmp byte [edi], 0xA
        je .EOF

        inc edi
    loop .array_size
    
    .EOF:
    ret

convert_number:
    mov esi, buffer ; iterate on buffer through esi
    add esi, 29
    xor edi, edi ; store result in edi
    mov ecx, 30
    mov ebx, 1 ; 1, 10, 100...

    xor eax, eax
    mov [number1], eax
    mov [number2], eax

    .array_size:
        cmp byte [esi], 0
        je .next
        cmp byte [esi], 0xA
        je .next
        cmp byte [esi], 0xD
        je .next
        cmp byte [esi], 0x20 ; second number
        je .second_number
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
    mov [number1], edi
    ret

    .second_number:
        cmp dword [number2], 0x0
        jne .second_number_next

        mov [number2], edi ; store number2
        xor edi, edi ; store number1 in edi
        mov ebx, 1

        .second_number_next:
            jmp .next

last_digit:
    mov eax, [number1] ; base number % 10
    xor edx, edx
    mov ebx, 10
    div ebx 
    
    cmp edx, 0
    je .l0
    cmp edx, 1
    je .l1
    cmp edx, 2
    je .l2
    cmp edx, 3
    je .l3
    cmp edx, 4
    je .l4
    cmp edx, 5
    je .l5
    cmp edx, 6
    je .l6
    cmp edx, 7
    je .l7
    cmp edx, 8
    je .l8
    cmp edx, 9
    je .l9

    .l0:
        mov eax, 0
        ret
    .l1:
        mov eax, 1
        ret
    .l2:
        mov eax, [number2] ; power % 4
        xor edx, edx
        mov ebx, 4
        div ebx

        cmp edx, 0
        je .l2_0
        cmp edx, 1
        je .l2_1
        cmp edx, 2
        je .l2_2
        cmp edx, 3
        je .l2_3

        .l2_0:
            mov eax, 6
            ret
        .l2_1:
            mov eax, 2
            ret
        .l2_2:
            mov eax, 4
            ret
        .l2_3:
            mov eax, 8
            ret
    .l3:
        mov eax, [number2] ; power % 4
        xor edx, edx
        mov ebx, 4
        div ebx

        cmp edx, 0
        je .l3_0
        cmp edx, 1
        je .l3_1
        cmp edx, 2
        je .l3_2
        cmp edx, 3
        je .l3_3

        .l3_0:
            mov eax, 1
            ret
        .l3_1:
            mov eax, 3
            ret
        .l3_2:
            mov eax, 9
            ret
        .l3_3:
            mov eax, 7
            ret
    .l4:
        mov eax, [number2]
        test eax, 0x1 ; power % 2 
        je .l4_0
        
        .l4_1:
            mov eax, 4
            ret
        .l4_0:
            mov eax, 6
            ret
        
    .l5:
        mov eax, 5
        ret
    .l6:
        mov eax, 6
        ret
    .l7:
        mov eax, [number2] ; power % 4
        xor edx, edx
        mov ebx, 4
        div ebx

        cmp edx, 0
        je .l7_0
        cmp edx, 1
        je .l7_1
        cmp edx, 2
        je .l7_2
        cmp edx, 3
        je .l7_3

        .l7_0:
            mov eax, 1
            ret
        .l7_1:
            mov eax, 7
            ret
        .l7_2:
            mov eax, 9
            ret
        .l7_3:
            mov eax, 3
            ret
    .l8:
        mov eax, [number2] ; power % 4
        xor edx, edx
        mov ebx, 4
        div ebx

        cmp edx, 0
        je .l8_0
        cmp edx, 1
        je .l8_1
        cmp edx, 2
        je .l8_2
        cmp edx, 3
        je .l8_3

        .l8_0:
            mov eax, 6
            ret
        .l8_1:
            mov eax, 8
            ret
        .l8_2:
            mov eax, 4
            ret
        .l8_3:
            mov eax, 2
            ret
    .l9:
        mov eax, [number2]
        test eax, 0x1 ; power % 2 
        je .l9_0

        .l9_1:
            mov eax, 9
            ret
        .l9_0:
            mov eax, 1
            ret

print_last_digit:
    push eax
    sub esp, 0x2

    add eax, '0'
    mov byte [esp], al
    mov eax, 0xA
    mov byte [esp+1], al

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, esp
    mov edx, 2
    int 80h
    
    add esp, 0x2
    pop eax
    ret

;_start:
main:
    call read_line
    call convert_number
    mov ecx, [number1]
    
    .iterate:
        push ecx

        call read_line
        call convert_number
        call last_digit
        call print_last_digit

        pop ecx
    loop .iterate
    
    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80


; nasm -f elf32 0003_LastDigitExponentiation.asm && gcc -no-pie 0003_LastDigitExponentiation.o -o 0003_LastDigitExponentiation

; debug version
; nasm -f elf32 -g -F dwarf 0003_LastDigitExponentiation.asm && gcc -fno-builtin -no-pie 0003_LastDigitExponentiation.o -o 0003_LastDigitExponentiation
; gdb 0003_LastDigitExponentiation -tui