; Great example from https://gist.github.com/nikAizuddin/f4132721126257ec4345

SYS_BRK equ 45

; ---- section read/write data -----------------------------------------
section .data

initial_break:
    dd 0x00000000
current_break:
    dd 0x00000000
new_break:
    dd 0x00000000

; ---- section instruction codes ---------------------------------------
section .text

; etext, edata, end, have nothing to do with brk().
extern etext ;The address of the end of the text segment.
extern edata ;The address of the end of the initialized data segment.
extern end   ;The address of the end of the uninitialized (bss segment).
; In gdb, type "x/x etext", "x/x edata", "x/x end" to check the value.
; Use "$ man 3 end" for more info.

global main
main:

; get current break address
;-----------------------------------------------------------------------
    mov    eax, SYS_BRK              ;system call brk
    mov    ebx, 0               ;invalid address
    int    0x80
    mov    [current_break], eax
    mov    [initial_break], eax

; allocate 8 bytes of memory on the heap
;-----------------------------------------------------------------------
    mov    eax, SYS_BRK              ;system call brk
    mov    ebx, [current_break]
    add    ebx, 8               ;allocate 8 bytes
    int    0x80
    mov    [new_break], eax
    mov    [current_break], eax

; allocate another 67108864 bytes of memory on the heap
;-----------------------------------------------------------------------
    mov    eax, SYS_BRK              ;system call brk
    mov    ebx, [current_break]
    add    ebx, 67108864        ;allocate 67108864 bytes
    int    0x80
    mov    [new_break], eax
    mov    [current_break], eax

.b0: ;Break the program here in GDB. Also watch the memory used by
     ;using "$ top" command.

; free all allocated memory on the heap
;-----------------------------------------------------------------------
    mov    eax, SYS_BRK              ;system call brk
    mov    ebx, [initial_break] ;reset break address to its initial addr
    int    0x80
    mov    [new_break], eax

.b1: ;Break the program here in GDB, to see the memory drop.

.exit:
    mov    eax, 0x01 ;system call exit
    mov    ebx, 0x00 ;return value := 0
    int    0x80

; nasm -f elf32 0019_MemoryManagment.asm && gcc -no-pie 0019_MemoryManagment.o -o 0019_MemoryManagment
; debug version
; nasm -f elf32 -g -F dwarf 0019_MemoryManagment.asm && gcc -fno-builtin -no-pie 0019_MemoryManagment.o -o 0019_MemoryManagment
; gdb 0019_MemoryManagment -tui
; p (int) initial_break - check variable value