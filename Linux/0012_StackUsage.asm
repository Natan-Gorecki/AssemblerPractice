SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1

section	.text
   global _start


section .data
    achar db ' ' 


_start:
    mov    ecx, 126-31
    next:
        push    ecx
        mov     ecx, achar
        call write_byte
        pop     ecx
        inc	byte [achar]
    loop    next

    mov	eax, SYS_EXIT
    int	0x80


write_byte:
    mov edx, 1
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    int 80h
    ret


; nasm -f elf 0012_StackUsage.asm && ld -m elf_i386 -s -o 0012_StackUsage 0012_StackUsage.o && ./0012_StackUsage