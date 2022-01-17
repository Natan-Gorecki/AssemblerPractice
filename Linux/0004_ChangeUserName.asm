section .data
    name db 'First  Surname', 0xa

section .text
    global _start

_start:

    ; write current name
    mov edx, 15
    mov ecx, name
    mov ebx, 1
    mov eax, 4
    int 80h

    ; Change name to "Second"
    mov [name], dword 'Seco'
    mov name[4], word 'nd'

    ; write changed name
    mov edx, 15
    mov ecx, name
    mov ebx, 1
    mov eax, 4
    int 80h

    ; exit
    mov eax, 1
    int 80h


; nasm -f elf 0004_ChangeUserName.asm
; ld -m elf_i386 -s -o 0004_ChangeUserName 0004_ChangeUserName.o
; ./0004_ChangeUserName