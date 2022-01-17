SYS_EXIT equ 1
SYS_READ equ 3
SYS_WRITE equ 4
STDIN equ 0
STDOUT equ 1


section .data
    entry_msg db 'Initial array with values: '
    entry_len equ $ - entry_msg

    final_msg db 'Sum value: '
    final_len equ $ - final_msg

    global array
    array:
        db 2
        db 3
        db 4

    sum db 0


section .text 
    global _start

_start:
    call entry_message
    call sum_items
    call final_message

    mov eax, SYS_EXIT
    int 0x80


entry_message:
    mov edx, entry_len
    mov ecx, entry_msg
    call write_stdout ; 'Initial array with values: '

    mov ecx, '0'
    add ecx, [array]
    call write_byte ; '2'

    mov ecx, ' '
    call write_byte ; ' '

    mov ecx, '0'
    add ecx, [array+1]
    call write_byte ; '3'

    mov ecx, ' '
    call write_byte ; ' '

    mov ecx, '0'
    add ecx, [array+2]
    call write_byte ; '4'
    
    
    ; new line
    mov ecx, 0xA
    call write_byte
    mov ecx, 0xD
    call write_byte

    ret


sum_items:
    mov eax, array ; current element
    mov ebx, 0 ; sum
    mov ecx, 3 ; number of iterations

    sum_loop:
        add ebx, [eax]
        add eax, 1
    loop sum_loop

    add ebx, '0'
    mov [sum], ebx

    ret


final_message:
    mov edx, final_len
    mov ecx, final_msg
    call write_stdout    

    mov edx, 1
    mov ecx, sum
    call write_stdout

    ; new line
    mov ecx, 0xA
    call write_byte
    mov ecx, 0xD    
    call write_byte

    ret

write_byte:
    mov edx, 1
    push ecx
    mov ecx, esp
    call write_stdout
    pop ecx
    ret


write_stdout:
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80
    ret


; nasm -f elf 0011_SimpleArrayInitialization.asm && ld -m elf_i386 -s -o 0011_SimpleArrayInitialization 0011_SimpleArrayInitialization.o && ./0011_SimpleArrayInitialization