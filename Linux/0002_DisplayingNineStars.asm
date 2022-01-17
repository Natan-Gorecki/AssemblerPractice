section .text
    global _start ; must be declared fo linker (gcc)

_start: ; tell linker entry point
    mov edx, len ; message length
    mov ecx, msg ; message to write
    mov ebx, 1 ; file descriptor (stdout)
    mov eax, 4 ; system call number (sys_write)
    int 0x80 ; call kernel

    mov edx, 10 ; message length 
    mov ecx, s2 ; message to write
    mov ebx, 1 ; file descriptor (stdout)
    mov eax, 4 ; system call number (sys_write)
    int 0x80 ; call kernel

    mov edx, 1 
    mov ecx, newLine
    mov ebx, 1 ; file descriptor (stdout)
    mov eax, 4 ; system call number (sys_write)
    int 0x80 ; call kernel

    mov eax, 1 ; system call number (sys_exit)
    int 0x80 ; call kernel

section .data
msg db 'Displaying 9 stars', 0xa ; message
len equ $ - msg ; length of message
newLine db 0xa
s2 times 9 db '*'

; nasm -f elf 0002_DisplayingNineStars.asm
; ld -m elf_i386 -s -o 0002_DisplayingNineStars 0002_DisplayingNineStars.o
; ./0002_DisplayingNindeStars