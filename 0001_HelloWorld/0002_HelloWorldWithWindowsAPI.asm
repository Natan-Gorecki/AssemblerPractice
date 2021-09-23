; https://stackoverflow.com/questions/1023593/how-to-write-hello-world-in-assembler-under-windows/1023600#1023600

global _start

extern _GetStdHandle@4
extern _WriteFile@20
extern _ExitProcess@4

section .text
_start:
    ; DWORD bytes
    mov ebp, esp
    sub esp, 4

    ; hStdOut - GetStdHandle( STD_OUTPUT_HANDLE )
    push -11
    call _GetStdHandle@4
    mov ebx, eax

    ; WriteFile( hStdOut, message, length(message), &bytes, 0 )
    push 0
    lea eax, [ebp-4]
    push eax
    push (message_end - message)
    push message
    push ebx
    call _WriteFile@20

    ; ExitProcess(0)
    push 0
    call _ExitProcess@4

    ; never here
    hlt

message:
    db 'Hello, World', 10
message_end:

; nasm -fwin32 0001_HelloWorldWithWindowsAPI.asm
; link /subsytem:console /nodefaultlib /entry:start 0002_HelloWorldWithWindowsAPI.obj kernel32.lib