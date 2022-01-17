SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .data
    newLine db 0xA, 0xD
    
    first_msg db 'First number: '
    first_len equ $ - first_msg

    second_msg db 'Second number: '
    second_len equ $ - second_msg

    result_msg db 'The result is: '
    result_len equ $ - result_msg

    sum times 6 db ' '


section .bss
    num1 resb 5
    num2 resb 5


section .text 
    global _start

_start:

    call first_label
    call second_label
    call loop_label
    call result_label

    mov eax, SYS_EXIT
    int 0x80


first_label:
    mov edx, first_len
    mov ecx, first_msg
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    mov edx, 5
    mov ecx, num1
    call GetNumber

    ret


second_label:
    mov edx, second_len
    mov ecx, second_msg
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    mov edx, 5
    mov ecx, num2
    call GetNumber
    int 0x80

    ret


loop_label:
    mov esi, 4 ; pointing to the rightmost digit
    mov ecx, 5 ; num of digits
    clc        ; clear carry flag

        add_loop:
    mov al, [num1 + esi]
    adc al, [num2 + esi] ; adc - add with carry 
    aaa
    pushf ; push flags register to stack
    or al, 30h
    popf

    mov [sum + esi + 1], al
    dec esi
    loop add_loop
    
    jnc loop_label_ret
    mov byte [sum], '1' ; last carry 
        loop_label_ret:
    ret


result_label:
    mov edx, result_len
    mov ecx, result_msg
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    mov edx, 6
    mov ecx, sum 
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    mov edx, 2
    mov ecx, newLine
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    ret


GetNumber:
    pusha                    ; save regs
get:
    mov eax, SYS_READ        ; system call for reading a character
    mov ebx, STDIN           ; 0 is standard input
    int 0x80                 ; ECX has the buffer, passed into GetNumber

    cmp byte [ecx],0x30
    jl get                   ; Retry if the byte read is < '0'
    cmp byte [ecx],0x39
    jg get                   ; Retry if the byte read is > '9'

    ; At this point, if you want to just return an actual number,
    ; you could subtract '0' (0x30) off of the value read
    popa               ; restore regs
    ret


; nasm -f elf 0010_AddTwo5DigitNumbers.asm && ld -m elf_i386 -s -o 0010_AddTwo5DigitNumbers 0010_AddTwo5DigitNumbers.o && ./0010_AddTwo5DigitNumbers