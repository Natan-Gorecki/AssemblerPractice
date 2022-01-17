SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .data
    init_msg db 'Input one digit (0-9): '
    init_len equ $ - init_msg

    even_msg db 'Even Number!', 0xA, 0xD
    even_len equ $ - even_msg

    odd_msg db 'Odd Number!', 0xA, 0xD
    odd_len equ $ - odd_msg


section .bss
    num resb 1


section .text 
    global _start


_start:

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, init_msg
    mov edx, init_len
    int 0x80

    ; get number from STDIN
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, num 
    mov edx, 1
    int 0x80

    ; check if digit is odd
    and byte [num], 1
    jz even
    jmp odd

even:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, even_msg
    mov edx, even_len
    int 0x80
    
    jmp outprog

odd:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, odd_msg
    mov edx, odd_len
    int 0x80

    jmp outprog

outprog:
    mov eax, SYS_EXIT
    int 0x80


; nasm -f elf 0007_DigitParityCheck.asm && ld -m elf_i386 -s -o 0007_DigitParityCheck 0007_DigitParityCheck.o && ./0007_DigitParityCheck