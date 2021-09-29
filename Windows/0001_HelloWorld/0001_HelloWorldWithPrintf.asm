; http://web.archive.org/web/20120414223112/http://www.cs.lmu.edu/~ray/notes/nasmexamples/

    global _main
    extern _printf

    section .text
_main:
    push message
    call _printf
    add esp, 4
    ret
message:
    db 'Hello, World!', 10, 0

; nasm -fwin32 0001_HelloWorldWithPrintf.asm
; gcc 0001_HelloWorldWithPrintf.asm -o 0001_HelloWorldWithPrintf.exe