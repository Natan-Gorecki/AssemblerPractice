// inspired by https://blog.holbertonschool.com/hack-virtual-memory-stack-registers-assembly-code/

#include <stdlib.h>
#include <stdio.h>

void secret() 
{
    printf("[x] This is secret message [x]\n");
    exit(98);
}

void func1() 
{ 
    // objdump -d 0005_hack_stack.out -j .text -M intel
    // 08049172 <secret>:

    register long ebp asm ("ebp");
    *(unsigned long int*)((char*)ebp + 4) = 0x08049172;

    printf("func1\n");
}

void func2() 
{
    printf("func2\n");
}

int main() 
{
    func1();
    func2();

    return EXIT_SUCCESS;    
}

// gcc -Wall -Wextra -pedantic -no-pie 0005_hack_stack.c -o 0005_hack_stack.out