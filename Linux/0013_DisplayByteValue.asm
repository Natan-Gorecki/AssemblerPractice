SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .data
    abyte db '9'


section	.text
   global _start


_start:
    mov al, [abyte]
    mov bl, 100 
    div bl

    hundreds:
        cmp al, 0 ; check if hundreds number is greater than 0
        je tens

        mov cl, al ; print quotient (hundreds number)
        push eax
        call write_byte_in_ascii
        pop eax
    
    tens:
        mov al, ah ; divide remainder by 10 divisor
        xor ah, ah
        mov bl, 10
        div bl

        cmp al, 0 ; check if tens number is greater than 0
        je unities

        mov cl, al ; print quotient (tens number)
        push eax
        call write_byte_in_ascii
        pop eax

    unities:
        mov cl, ah ; print remainder (unities number)
        call write_byte_in_ascii

        call new_line

    mov	eax, SYS_EXIT
    int	0x80

new_line:
    mov edx, 1
    mov ecx, 0xA
    push ecx
    mov ecx, esp
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 80h
    pop ecx

    mov edx, 1
    mov ecx, 0xD
    push ecx
    mov ecx, esp
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 80h
    pop ecx

    ret

write_byte_in_ascii:
    add ecx, '0'
    push ecx

    mov edx, 1
    mov ecx, esp
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 80h

    pop ecx
    ret


; debug version
; nasm -f elf -g -F dwarf 0013_DisplayByteValue.asm && ld -m elf_i386 -o 0013_DisplayByteValue 0013_DisplayByteValue.o && ./0013_DisplayByteValue
; gdb 0013_DisplayByteValue -tui