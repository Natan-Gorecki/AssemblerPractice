SYS_EXIT equ 1

section .bss    
    number1 resb 8
    number2 resb 8

section .data
    formatin: db "%lf %lf", 0
    formatout: db "%.2lf", 0xA, 0

section	.text
    extern printf
    extern scanf
    ;global _start
    global main

;_start:
main:
    ; arguments are from right to left
    push number2
    push number1
    push formatin
    call scanf
    add esp, 12
    
    mov eax, 4
    push eax

    fld qword [number1]
    fld st0
    fmulp                   ; d*d
    fld qword [number2]      
    fld st0                  
    fmulp                   ; r*r
    fild dword [esp]        ; 4
    fdivp                   ; d*d/4
    fsub
    fldpi                   ; PI
    fmulp                   ; (r*r - d*d/4)*PI

    pop eax
    sub esp, 8
    fstp qword [esp]
    push formatout
    call printf

    add esp, 12
    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80

; nasm -f elf32 0010_FloatingPointNumbers.asm && gcc -no-pie 0010_FloatingPointNumbers.o -o 0010_FloatingPointNumbers    

; debug version
; nasm -f elf32 -g -F dwarf 0010_FloatingPointNumbers.asm && gcc -fno-builtin -no-pie 0010_FloatingPointNumbers.o -o 0010_FloatingPointNumbers
; gdb 0010_FloatingPointNumbers -tui