SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section .data
    msg db "Factorial of 3 is: "
    len equ $ - msg
    newLine db 0xa, 0xd
    result resb 1

section .text
    global main

main:
    mov bx, 3
    call factorial
    add ax, '0'
    mov [result], ax
    
    call display_result

    mov eax, SYS_EXIT
    int 80h

factorial:
    cmp bl, 1
    jg factorial_work
    mov ax, 1

    ret

factorial_work:
    dec bl
    call factorial
    inc bl
    mul bl ; ax = al * bl

    ret

display_result:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg
    mov edx, len
    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, result
    mov edx, 1
    int 80h

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newLine
    mov edx, 2
    int 80h

    ret

; nasm -f elf32 0016_Factorial.asm && gcc -no-pie 0016_Factorial.o -o 0016_Factorial && ./0016_Factorial