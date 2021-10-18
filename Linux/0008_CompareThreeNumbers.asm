SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .data
    msg db 'The largest number is: '
    msg_len equ $ - msg

    newLine db 0xA, 0xD

    num1 dd '47'
    num2 dd '22'
    num3 dd '31'


section .bss
    largest resb 2


section .text 
    global _start


_start:
    mov ecx, [num1]
    cmp ecx, [num2]
    
    jg check_third_num ; num1 is greater
    mov ecx, [num2]    ; num2 is greater     

        check_third_num:

    cmp ecx, [num3]    ; num1/num2 is winner
    
    jg exit
    mov ecx, [num3]    ; num3 is winner

        exit:
    
    mov [largest], ecx

    mov edx, msg_len
    mov ecx, msg
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    mov edx, 2
    mov ecx, largest
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    mov edx, 2
    mov ecx, newLine
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    mov eax, SYS_EXIT
    int 0x80


; nasm -f elf 0008_CompareThreeNumbers.asm && ld -m elf_i386 -s -o 0008_CompareThreeNumbers 0008_CompareThreeNumbers.o && ./0008_CompareThreeNumbers