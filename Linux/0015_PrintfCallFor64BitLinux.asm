section .data;
        msg: db "Hello World!", 10

section .text
    global  main
    extern printf    

main:
    lea rdi,[rel msg]
    xor rax,rax 

    ;Referring to a procedure name using wrt ..plt causes the linker to build a procedure linkage table entry for the symbol, 
    ;and the reference gives the address of the PLT entry. You can only use this in contexts which would generate a PC-relative
    ;relocation normally (i.e. as the destination for CALL or JMP), since ELF contains no relocation type to refer to PLT entries absolutely.
    call printf wrt ..plt 
    ret 


;nasm -f elf64 0015_PrintfCallFor64BitLinux.asm && gcc -no-pie 0015_PrintfCallFor64BitLinux.o -o 0015_PrintfCallFor64BitLinux.out && ./0015_PrintfCallFor64BitLinux.out