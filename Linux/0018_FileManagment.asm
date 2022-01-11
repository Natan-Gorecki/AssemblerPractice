SYS_READ equ 3
SYS_WRITE equ 4
SYS_OPEN equ 5
SYS_CLOSE equ 6
SYS_CREATE equ 8
STDOUT equ 1

%macro write_string 2
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, %1
    mov edx, %2
    int 80h
%endmacro

%macro close_file 1
    mov eax, SYS_CLOSE
    mov ebx, %1
    int 80h
%endmacro


section .data
    file_name db '0018_FileManagment.txt', 0
    
    msg db 'Hello World with NASM assembly', 0xa, 0xd
    msg_len equ $ - msg
    
    msg_done db 'Written to file', 0xa, 0xd
    msg_done_len equ $ - msg_done


section .bss 
    fd_out resb 1
    fd_in resb 1
    info resb 26


section .text
    global main

main:
    call create_file
    call write_into_file
    close_file [fd_out]
    write_string msg_done, msg_done_len
    call open_file
    call read_from_file
    close_file [fd_in]
    write_string info, 32
    mov eax, 0
    int 80h

create_file:
    mov eax, SYS_CREATE
    mov ebx, file_name
    mov ecx, 0777 ; read, write and execute by all
    int 80h

    mov [fd_out], eax
    ret

write_into_file:
    mov eax, SYS_WRITE
    mov ebx, [fd_out]
    mov ecx, msg
    mov edx, msg_len
    int 80h

    ret

open_file:
    mov eax, SYS_OPEN
    mov ebx, file_name
    mov ecx, 0 ; for read only access
    mov edx, 0777 ; read, write and execute by all
    int 80h

    mov [fd_in], eax
    ret

read_from_file:
    mov eax, SYS_READ
    mov ebx, [fd_in]
    mov ecx, info 
    mov edx, 32
    int 80h
    
    ret

; nasm -f elf32 0018_FileManagment.asm && gcc -no-pie 0018_FileManagment.o -o 0018_FileManagment && ./0018_FileManagment