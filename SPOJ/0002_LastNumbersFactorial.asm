SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .bss    
    buffer resb 20
    number resb 4


section	.text
   ;global _start
   global main


read_line:
    mov edi, buffer
    mov ecx, 10
    .clear:
        mov word [edi], 0
        add edi, 2
    loop .clear

    mov edi, buffer
    mov ecx, 20
    .array_size:
        push ecx;

        mov eax, SYS_READ ; sys_write
        mov ebx, STDIN ; stdout
        mov ecx, edi
        mov edx, 1
        int 80h

        pop ecx;
        
        cmp byte [edi], 0xA
        je .EOF

        inc edi
    loop .array_size
    
    .EOF:
    ret

convert_number:
    mov esi, buffer ; iterate on buffer through esi
    add esi, 19
    xor edi, edi ; store result in edi
    mov ecx, 20
    mov ebx, 1 ; 1, 10, 100...

    .array_size:
        cmp byte [esi], 0
        je .next
        cmp byte [esi], 0xA
        je .next
        cmp byte [esi], 0xD
        je .next
        cmp byte [esi], '0'
        jl .return 
        cmp byte [esi], '9'
        jg .return

        xor eax, eax
        mov al, [esi]
        sub eax, '0'
        
        mul ebx
        add edi, eax
        
        mov eax, ebx
        mov ebx, 10
        mul ebx
        mov ebx, eax

    .next:
        dec esi
    loop .array_size

    .return:
    mov [number], edi
    ret

print_last_numbers:
    mov eax, [number] ; number <= 1
    cmp eax, 0x1
    jbe .l1

    cmp eax, 0xa
    jae .l10
    cmp eax, 0x2
    je .l2
    cmp eax, 0x3
    je .l3
    cmp eax, 0x4
    je .l4
    cmp eax, 0x5
    je .l5
    cmp eax, 0x6
    je .l6
    cmp eax, 0x7
    je .l7
    cmp eax, 0x8
    je .l8
    cmp eax, 0x9
    je .l9

    .l1:
    push `0 1\n`
    jmp .print
    .l2:
    push `0 2\n`
    jmp .print
    .l3:
    push `0 6\n`
    jmp .print
    .l4:
    push `2 4\n`
    jmp .print
    .l5:
    .l6:
    .l8:
    push `2 0\n`
    jmp .print
    .l7:
    push `4 0\n`
    jmp .print
    .l9:
    push `8 0\n`
    jmp .print
    .l10:
    push `0 0\n`
    jmp .print

    .print:
        mov eax, SYS_WRITE 
        mov ebx, STDOUT
        mov ecx, esp
        mov edx, 4
        int 80h
        
        add esp, 4
        ret

;_start:
main:
    call read_line
    call convert_number
    mov ecx, [number]
    
    .iterate:
        push ecx

        call read_line
        call convert_number
        call print_last_numbers

        pop ecx
    loop .iterate
    
    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80


; nasm -f elf32 0002_LastNumbersFactorial.asm && gcc -no-pie 0002_LastNumbersFactorial.o -o 0002_LastNumbersFactorial