SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .bss    
    buffer resb 10
    number resb 4


section	.text
   ;global _start
   global main


read_line:
    mov edi, buffer
    mov ecx, 5
    .clear:
        mov word [edi], 0
        add edi, 2
    loop .clear

    mov edi, buffer
    mov ecx, 10
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
    add esi, 9
    xor edi, edi ; store result in edi
    mov ecx, 10
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

is_prime:
    mov esi, [number] ; number <= 1
    cmp esi, 1
    jle .no

    cmp esi, 3 ; number <= 3
    jle .yes
    
    test esi, 0x1 ; number % 2 == 0
    je .no

    mov eax, esi ; number % 3 == 0
    xor edx, edx
    mov ebx, 3 
    div ebx 
    cmp edx, 0
    je .no
    
    mov ecx, 5 ; i = 5
    .while:
        mov eax, ecx ; i * i <= number
        mul ecx
        cmp eax, esi 
        jg .yes

        mov eax, esi ; number % i == 0
        xor edx, edx
        div ecx 
        cmp edx, 0
        je .no

        mov eax, esi ; number % (i + 2) == 0
        xor edx, edx
        mov ebx, ecx 
        add ebx, 2
        div ebx
        cmp edx, 0
        je .no        

        add ecx, 6 ; i = i + 6
    jmp .while

    .yes:
        push `TAK\n`
        
        mov eax, SYS_WRITE 
        mov ebx, STDOUT
        mov ecx, esp
        mov edx, 4
        int 80h
        
        add esp, 4
        ret
    .no:
        push `NIE\n`
        
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
        call is_prime

        pop ecx
    loop .iterate
    
    mov	eax, SYS_EXIT
    xor ebx, ebx
    int	0x80


; nasm -f elf32 0001_PrimeNumbers.asm && gcc -no-pie 0001_PrimeNumbers.o -o 0001_PrimeNumbers

; debug version
; nasm -f elf32 -g -F dwarf 0001_PrimeNumbers.asm && gcc -fno-builtin -no-pie 0001_PrimeNumbers.o -o 0001_PrimeNumbers
; gdb 0001_PrimeNumbers -tui