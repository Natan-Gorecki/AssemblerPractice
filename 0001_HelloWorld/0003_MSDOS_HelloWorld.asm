; NOT WORKING ON WIN-64, EXAMPLE OF PREVIOUS ASSEMBLY PROGRAMMING


; https://ww2.ii.uj.edu.pl/~kapela/pn/print-one-lecture.php?lectureNumber=3
; https://stackoverflow.com/questions/22829044/hello-world-in-nasm-without-windows-api

; A 32-bit Windows system will run a 16-bit DOS program. 
; However, 64-bit Windows systems no longer have the MS-DOS subsystem/emulation so it won't work there.
; You'll need to use the Windows APIs, or if you're more adventurous the native NT APIs
; (which are pretty similar, but generally not documented). 
; The actual system dispatch mechanism used is very processor and Windows version dependent. 


org 0x100

section .data
    info: db "Hello world!", 13, 10, '$' ; 13, 10 gives new line
                                         ; '$' sign is required by function
                                    
section .bss
    bufor: resb 5 ; bufor 5 bytes

section .text ; code section

    mov ah, 9
    mov dx, info
    int 0x21 ; when 9 will be loaded to ah registry, registry dx content will be shown

    mov ah, 0
    int 0x16 ; when 0 will be loaded to ah registry, program waits for a key to be passed

    mov ax, 0x4C00 ; exit program with 0 code
                   ; ah registry contains 4C
                   ; al registry contains 00

    int 0x21


; nasm -fbin -o 0002_WindowsHelloWorld.obj 0002_WindowsHelloWorld.asm
; ...