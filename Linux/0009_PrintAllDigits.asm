SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .data
    newLine db 0xA, 0xD


section .bss
    num resb 1


section .text 
    global _start

_start:
    mov ecx, 10
    mov byte [num], '0'

loop_label:
    push ecx

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, num
    mov edx, 1
    int 0x80

    pop ecx

    jmp increase_digit
        increase_digit_return:    
    loop loop_label


    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newLine
    mov edx, 2
    int 0x80

    mov eax, SYS_EXIT
    int 0x80


increase_digit:
    mov eax, [num]
    sub eax, '0'
    inc eax
    add eax, '0'
    mov [num], eax

    jmp increase_digit_return

; nasm -f elf 0009_PrintAllDigits.asm && ld -m elf_i386 -s -o 0009_PrintAllDigits 0009_PrintAllDigits.o && ./0009_PrintAllDigits