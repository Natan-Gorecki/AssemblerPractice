#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

/**
 * main - do nothing
 *
 * Return: EXIT_FAILURE if something failed. Otherwise EXIT_SUCCESS
 */

/**
 * pmem - print mem
 * @p: memory address to start printing from
 * @bytes: number of bytes to print
 *
 * @return nothing
 */
void pmem(void *p, unsigned int bytes)
{
    unsigned char *ptr;

    ptr = (unsigned char*)p;
    for(unsigned int i=0; i<bytes; i++) 
    {
        if(i != 0) printf(" ");

        printf("%02x", *(ptr + i));
    }
    printf("\n");
}

int main() 
{
    void* memory;
    size_t size_of_the_chunk;
    size_t size_of_the_previous_chunk;
    void* chunks[10];
    char prev_used;


    for(int i=0; i<10; i++) 
    {
        memory = malloc(1024 * (i + 1));
        chunks[i] = (void*)((char*)memory-0x10);
        printf("[%d]: %p\n", i, memory);
    }
    printf("\n");


    free((char*)chunks[3]+0x10);
    free((char*)chunks[7]+0x10);


    for(int i=0; i<10; i++)
    {
        printf("-----[%d]-----\n", i);
        memory = chunks[i];
        pmem(memory, 0x10);
        size_of_the_chunk = *((size_t*)((char*)memory+12));
        prev_used = size_of_the_chunk & 1;
        size_of_the_chunk -= prev_used;
        size_of_the_previous_chunk = *((size_t*)((char*)memory+8));

        printf("Chunk pointer: %p\n", memory);
        printf("Chunk size: %lu\n", (unsigned long)size_of_the_chunk);
        printf("Previous chunk size (%s): %lu\n\n",(prev_used ? "allocated" : "unallocated") , (unsigned long)size_of_the_previous_chunk);
    }
    

    return EXIT_SUCCESS;    
}

// gcc -Wall -Wextra -pedantic -no-pie -Werror 0004_inspect_heap.c -o 0004_inspect_heap.out