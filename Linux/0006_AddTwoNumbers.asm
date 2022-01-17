SYS_EXIT  equ 1
SYS_READ  equ 3
SYS_WRITE equ 4
STDIN     equ 0
STDOUT    equ 1

section .data
    msg1 db 'Enter a digit: '
    len1 equ $ - msg1

    msg2 db 'Enter a second digit: '
    len2 equ $ - msg2

    msg3 db "The sum is: "
    len3 equ $ - msg3

    newLine db 0xA, 0xD

section .bss    
    num1 resb 2
    num2 resb 2
    res  resb 2

section .text
    global _start ; must be declared for using gcc

_start: ; tell linker entry point
    
    ; FIRST NUMBER

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg1
    mov edx, len1
    int 0x80

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, num1
    mov edx, 2
    int 0x80

    ; SECOND NUMBER

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg2
    mov edx, len2
    int 0x80

    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, num2
    mov edx, 2
    int 0x80

    ; RESULT

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg3
    mov edx, len3
    int 0x80

    ; moving the first number to EAX register and second number to EBX register
    ; and substracing ascii '0' to convert it into decimal number

    mov eax, [num1]
    sub eax, '0'

    mov ebx, [num2]
    sub ebx, '0'

    ; add '0' to convert the sum from decimal number to ASCII
    add eax, ebx
    add eax, '0'

    mov [res], EAX

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, res
    mov edx, 1
    int 0x80

    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, newLine
    mov edx, 2
    int 0x80

exit:
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80


; nasm -f elf 0006_AddTwoNumbers.asm && ld -m elf_i386 -s -o 0006_AddTwoNumbers 0006_AddTwoNumbers.o && ./0006_AddTwoNumbers