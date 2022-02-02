// inspired by https://blog.holbertonschool.com/hack-virtual-memory-stack-registers-assembly-code/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

void func1() 
{ 
    int a;
    int b;
    int c;
    
    register long esp asm ("esp");
    register long ebp asm ("ebp");

    a = 98;
    b = 972;
    c = a + b;

    printf("func1, a = %d, b = %d, c = %d\n", a, b, c);

    printf("func1, ebp = %lx\n", ebp);
    printf("func1, esp = %lx\n", esp);
    // ebp - esp = 0x10 + 0x8 (when using printf)

    printf("func1, a = %d\n", *(int*)((char*)ebp - 0xc));
    printf("func1, b = %d\n", *(int*)((char*)ebp - 0x10));
    printf("func1, c = %d\n", *(int*)((char*)ebp - 0x14));
    
    printf("func1, previous ebp value = %lx\n", *(unsigned long int*)ebp);
    printf("func1, return address value = %lx\n\n", *(unsigned long int*)((char*)ebp + 4));
}

void func2() 
{
    int a;
    int b;
    int c;

    register long ebp asm ("ebp");
    register long esp asm ("esp");
    
    printf("func2, a = %d, b = %d, c = %d\n", a, b, c);
    
    printf("func2, ebp = %lx\n", ebp);
    printf("func2, esp = %lx\n\n", esp);
}

int main() 
{
    register long ebp asm ("ebp");
    register long esp asm ("esp");

    printf("main, ebp = %lx\n", ebp);
    printf("main, esp = %lx\n\n", esp);

    func1();
    func2();

    return EXIT_SUCCESS;    
}

// gcc -Wall -Wextra -pedantic -no-pie 0005_inspect_stack.c -o 0005_inspect_stack.out