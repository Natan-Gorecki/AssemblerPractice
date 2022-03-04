; < 2000 BYTES!!!
%macro WRT 2
    mov eax, 4
    mov ebx, 1
    lea ecx, [%1]
    mov edx, %2
    int 80h
%endmacro
section .bss    
    bf resb 240
    nmb resb 1

section	.text
   ;global _start
   global main

rl:
    mov edi,bf
    mov ecx,240
    .a:
        push ecx;

        mov eax,3
        mov ebx,0
        mov ecx,edi
        mov edx,1
        int 80h

        pop ecx;
        
        cmp eax,0;
        je .e
        cmp byte [edi],10
        je .e

        inc edi
    loop .a    
    .e:
    mov byte [edi],10
    ret

cvn:
    mov esi,bf
    add esi,2
    xor edi,edi
    mov ecx,3
    mov ebx,1

    .a:
        xor eax,eax
        mov al,[esi]

        cmp al,0
        je .n
        cmp al,10
        je .n
        cmp al,13
        je .n
        cmp al,48
        jl .e
        cmp al,57
        jg .e
        
        sub al,48        
        mul ebx
        add edi,eax
        
        mov eax,ebx
        mov ebx,10
        mul ebx
        mov ebx,eax
    .n:
        dec esi
    loop .a
    .e:
    mov [nmb],edi
    ret

pn:
    push eax

    xor edx,edx
    mov ebx,100
    div ebx
    add eax,48
    mov [esp],al

    mov eax,edx
    xor edx,edx
    mov ebx,10
    div ebx
    add al,48
    add dl,48
    mov [esp+1],al
    mov [esp+2],dl

    cmp byte [esp],48
    je .t
    WRT esp,1

    .t:
        cmp byte [esp+1],48
        je .zt
        WRT esp+1,1
        jmp .u
    .zt:
        cmp byte [esp],48
        je .u
        WRT esp+1,1

    .u:
        WRT esp+2,1
    pop eax
    ret

pdc:
    push eax
    mov edi,ebx
    
    cmp ebx,2
    jg .c3
    cmp ebx,1
    jg .c2
    cmp ebx,0
    jg .c1
    jmp .e

    .c1:
        WRT esp,1
        jmp .e
    .c3:    
        WRT esp,1
        mov eax,edi
        call pn
        jmp .e
    .c2:
        mov byte [esp],al
        mov byte [esp+1],al
        WRT esp,2
        jmp .e
    .e:
        pop eax
        ret
        
rdc:
    sub esp,2
    mov byte [esp+1],0
    mov byte [esp],0
    mov esi, bf
    mov ecx, 240
     
    .i:
        mov al,[esi]
        cmp al,0
        je .e
        cmp al,10
        je .e
        cmp al,13
        je .e
        
        mov al,[esp+1]
        cmp [esi],al
        je .sc
        .dc:

            mov al,[esp+1]
            mov bl,[esp]
            push esi
            call pdc
            pop esi
            mov al,[esi]
            mov [esp+1],al
            mov byte [esp],1
            jmp .n

        .sc:
            inc byte [esp]
            jmp .n

        .n:
            inc esi
    loop .i
    .e:
        mov al,[esp+1]
        mov bl,[esp]
        push esi
        call pdc
        pop esi

        mov byte [esp],13
        mov byte [esp+1],10
        WRT esp,2

        add esp,2
        ret

;_start:
main:
    call rl
    call cvn
    mov ecx, [nmb]
    .i:
        push ecx
        call rl
        call rdc
        pop ecx
    loop .i
    mov	eax, 1
    xor ebx, ebx
    int	0x80

; nasm -f elf32 0004_RemoveDuplicatedChars_Compressed.asm && gcc -no-pie 0004_RemoveDuplicatedChars_Compressed.o -o 0004_RemoveDuplicatedChars_Compressed

; debug version
; nasm -f elf32 -g -F dwarf 0004_RemoveDuplicatedChars_Compressed.asm && gcc -fno-builtin -no-pie 0004_RemoveDuplicatedChars_Compressed.o -o 0004_RemoveDuplicatedChars_Compressed
; gdb 0004_RemoveDuplicatedChars_Compressed -tui