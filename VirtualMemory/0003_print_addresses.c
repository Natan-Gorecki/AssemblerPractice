//insipired by https://blog.holbertonschool.com/hack-the-virtual-memory-drawing-the-vm-diagram/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/**
 * main - print locations of stack variable
 * 
 * Return EXIT_FAILURE if something failed, otherwise EXIT_SUCCESS
 */
int main(int argc, char** argv, char** env)
{
    //****************************************************************
    // Stack
    //****************************************************************
    int stack_variable = 3;
    printf("Address of stack variable: %p\n", (void*)&stack_variable);


    //****************************************************************
    // Heap
    //****************************************************************
    void *heap_variable;
    heap_variable = malloc(98);
    if(heap_variable == NULL) 
    {
        fprintf(stderr, "Cannot allocate memory with malloc\n");
        return EXIT_FAILURE;
    }
    printf("Address of heap variable: %p\n", heap_variable);


    //****************************************************************
    // Main function
    //****************************************************************
    printf("Address of function main: %p\n", (void*)main);
    
    // objdump -M intel -j .text -d 2 | grep '<main>:' -A 5
    printf("\tMain memory: ");
    for(int i=0; i<15; i++)
    {
        printf("%02x ", ((unsigned char*)main)[i]);
    }
    printf("\n");


    //****************************************************************
    // Main arguments
    //****************************************************************
    printf("Address of the array of the arguments: %p\n", (void*)argv);
    printf("Addresses of the arguments:\n");
    for(int i=0; i<argc; i++) 
    {
        printf("\t[%s]:%p\n", argv[i], argv[i]);
    }


    //****************************************************************
    // Environment variables
    //****************************************************************
    printf("Address of the array of the environment variables: %p\n", (void*)env);
    printf("Addresses of the environment variable:\n");
    int env_count = 0;
    for(char** ptr = env; *ptr != 0; ptr++) 
    {
        env_count++;
        printf("\t[%s]:%p\n", *ptr, *ptr);
    }
    int env_bytes = sizeof(char*) * env_count;
    printf("Size of the array of the environment variables: %d elements -> %d bytes (0x%x)\n", env_count, env_bytes, env_bytes);


    //****************************************************************
    // Stack growing downwards
    //****************************************************************
    int a;
    int b;
    int c;

    a = 98;
    b = 1024;
    c = a * b;
    printf("[f] a = %d, b = %d, c = a * b = %d\n", a, b, c);
    printf("[f] Addresses of variables: a = %p, b = %p, c = %p\n", (void*)&a, (void*)&b, (void*)&c);

    getchar();
    return EXIT_SUCCESS;
}

/* gcc -Wall -Wextra -Werror -no-pie 0003_print_addresses.c -o 0003_print_addresses.out
*
* -no-pie
* Position Independent Executables (PIE) are an output of the hardened package build process.
* A PIE binary and all of its dependencies are loaded into random locations within virtual memory each time the application is executed.
* This makes Return Oriented Programming (ROP) attacks much more difficult to execute reliably.
*/