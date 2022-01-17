section .data
    message db  'Hello, World', 10, 0


section .text
    global  main
    extern  printf


main:
    push    message
    call    printf
    add     esp, 4
    ret


; LD
; nasm -f elf32 0014_PrintfCallFor32BitLinux.asm && ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o 0014_PrintfCallFor32BitLinux /usr/lib/gcc/i686-linux-gnu/10/../../../i386-linux-gnu/crt1.o /usr/lib/gcc/i686-linux-gnu/10/../../../i386-linux-gnu/crti.o  -L/usr/lib/gcc/i686-linux-gnu/10 0014_PrintfCallFor32BitLinux.o -lc -lgcc /usr/lib/gcc/i686-linux-gnu/10/../../../i386-linux-gnu/crtn.o && ./0014_PrintfCallFor32BitLinux && ./0014_PrintfCallFor32BitLinux
; GCC
; nasm -f elf32 0014_PrintfCallFor32BitLinux.asm && gcc -no-pie 0014_PrintfCallFor32BitLinux.o -o 0014_PrintfCallFor32BitLinux && ./0014_PrintfCallFor32BitLinux