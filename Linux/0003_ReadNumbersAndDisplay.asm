section .data
    userMsg db 'Please enter a number: '
    lenUserMsg equ $ - userMsg
    displayMsg db 'You have entered:'
    lenDisplayMsg equ $ - displayMsg
    newLine db 0xa


section .bss ; unitialized data
    num resb 5


section .text
    global _start


_start:
    ; Initial message
    mov eax, 4 ; sys_write
    mov ebx, 1 ; stdout
    mov ecx, userMsg
    mov edx, lenUserMsg
    int 80h

    ; Read and store user input
    mov eax, 3 ; sys_read
    mov ebx, 2 ; ? 
    mov ecx, num
    mov edx, 5 ; 5 bytes (numeric, 1 for sign) of that information
    int 80h

    ; Output message
    mov eax, 4
    mov ebx, 1
    mov ecx, displayMsg
    mov edx, lenDisplayMsg
    int 80h

    ; Output number
    mov eax, 4
    mov ebx, 1
    mov ecx, num
    mov edx, 5
    int 80h

    ; Newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newLine
    mov edx, 1
    int 80h

    ; Exit
    mov eax, 1
    mov ebx, 0
    int 80h


; nasm -f elf 0003_ReadNumbersAndDisplay.asm
; ld -m elf_i386 -s -o 0003_ReadNumbersAndDisplay 0003_ReadNumbersAndDisplay.o
; ./0003_ReadNumbersAndDisplay