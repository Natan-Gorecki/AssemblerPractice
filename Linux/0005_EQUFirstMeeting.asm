SYS_EXIT equ 1
SYS_WRITE equ 4
STDOUT equ 1

section .data
    msg1 db 'Hello, World!', 0xA, 0xD
    len1 equ $ - msg1

    msg2 db 'Welcome to the NASM', 0xA, 0xD
    len2 equ $ - msg2

    msg3 db 'Linux assembly programming', 0xA, 0xD
    len3 equ $ - msg3

section .text
    global _start ; must be declared for using gcc

_start:
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, len1
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg2
    mov edx, len2
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg3
    mov edx, len3
    int 0x80

    mov eax, SYS_EXIT
    int 0x80

; nasm -f elf 0005_EQUFirstMeeting.asm
; ld -m elf_i386 -s -o 0005_EQUFirstMeeting 0005_EQUFirstMeeting.o
; ./0005_EQUFirstMeeting
