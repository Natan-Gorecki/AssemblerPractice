// inspired by https://blog.holbertonschool.com/hack-the-virtual-memory-c-strings-proc/

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/*
* Locates and replaces the first occurrence of a string in the heap of a process
*
* Usage ./0001_read_write_heap PID search_string replace_by_string
* Where:
*  - PID is the pid of the target process
*  - search_string is the ASCII string you are looking to overwrite
*  - replace_by_string is the ASCII string you want to replace search_string with
*/
char* find_string(char* string, long string_length, const char* substring);

int main(int argc, char* argv[])
{
    // args validation
    if (argc != 4)
    {
        printf("Usage: %s PID search_string replace_by_string\n", argv[0]);
        return 1;
    }

    int pid = atoi(argv[1]);
    if (pid <= 0)
    {
        printf("Usage: %s PID search_string replace_by_string\n", argv[0]);
        return 2;
    }


    // find file paths
    char maps_filename[100];
    memset(maps_filename, '\0', 100);
    sprintf(maps_filename, "/proc/%d/maps", pid);
    printf("[*] maps: %s\n", maps_filename);

    char mem_filename[100];
    memset(mem_filename, '\0', 100);
    sprintf(mem_filename, "/proc/%d/mem", pid);
    printf("[*] mem: %s\n", mem_filename);


    // open files
    FILE* maps_file = fopen(maps_filename, "r");
    if (maps_file == NULL)
    {
        printf("[ERROR] Can not open file %s:", maps_filename);
        return 3;
    }
    FILE* mem_file = fopen(mem_filename, "rb+");
    if (maps_file == NULL)
    {
        printf("[ERROR] Can not open file %s:", mem_filename);
        return 4;
    }


    const int maps_buffer_length = 255;
    char maps_buffer[maps_buffer_length];
    bool mem_values_readed = false;
    char* addr, * perm, * offset, * device, * inode;
    char* addr_start, * addr_end;


    // read from /proc/[pid]/maps file
    while (fgets(maps_buffer, maps_buffer_length, maps_file))
    {
        char* pathname = strstr(maps_buffer, "[heap]");
        if (pathname)
        {
            addr = maps_buffer;

            addr = strtok(maps_buffer, " ");
            perm = strtok(NULL, " ");
            offset = strtok(NULL, " ");
            device = strtok(NULL, " ");
            inode = strtok(NULL, " ");
            pathname = strtok(NULL, " \n");

            printf("[*] Found [heap]:\n");
            printf("\tpathname = %s\n", pathname);
            printf("\taddresses = %s\n", addr);
            printf("\tpermisions = %s\n", perm);
            printf("\toffset = %s\n", offset);
            printf("\tdevice = %s\n", device);
            printf("\tinode = %s\n", inode);

            addr_start = strtok(addr, " -\0");
            addr_start = (char*)strtol(addr_start, NULL, 16);
            addr_end = strtok(NULL, " -\0");
	        addr_end = (char*)strtol(addr_end, NULL, 16);
            printf("\taddr start [%p] | end [%p]\n", (void*)addr_start, (void*)addr_end);

            // check if there is read and write permission
            if (perm[0] != 'r' || perm[1] != 'w')
            {
                printf("[*] %s does not have read/write permission\n", pathname);
                return 5;
            }

            mem_values_readed = true;
            break;
        }
        continue;
    }


    // read from/write to /proc/[pid]/mem file
    if (mem_values_readed)
    {
        int seek_result = fseek(mem_file, (long)addr_start, SEEK_SET);
        if(seek_result != 0) 
        {
            printf("[ERROR] Cannot seek to specified address %ld\n", (long)addr_start);
            return 6;
        }

        const long mem_buffer_length = (long)addr_end - (long)addr_start;
        unsigned char mem_buffer[mem_buffer_length];

        size_t read_result = fread(mem_buffer, sizeof(char), mem_buffer_length, mem_file);
        if (read_result == 0)
        {
            printf("[ERROR] Cannot read heap from file %s\n", mem_filename);
            return 8;
        }

        /* Printf heap memory

        printf("Readed %d bytes from mem file\n", read_result);
        int counter = 0;
        for(long i=0; i< mem_buffer_length; i++) {
            if((int)mem_buffer[i] == 0) {
                counter++;
            }
            else {
                if(counter != 0)
                {
                    printf("0(%d times) ", counter);
                    counter = 0;
                }
                printf("%d ", (int)mem_buffer[i]);
            }
        }
        printf("\n");
        */


        // find if heap contain string to overwrite
        char* search_string = find_string((char*)mem_buffer, mem_buffer_length, argv[2]);
        if (search_string == NULL)
        {
            printf("[ERROR] Can't find: %s\n", argv[2]);
            return 9;
        }
        printf("[*] Found %s at %p\n", search_string, (void*)search_string);


        // seek to correct place 
        long offset = (long)search_string - (long)mem_buffer;
        seek_result = fseek(mem_file, (long)addr_start + offset, SEEK_SET);
        if(seek_result != 0) 
        {
            printf("[ERROR] Cannot seek to specified address %ld\n", (long)addr_start + offset);
            return 10;
        }

        // write the new string
        printf("[*] Writing %s at %p\n", argv[3], (void*)search_string);
        size_t write_result = fwrite(argv[3], sizeof(char), strlen(argv[3]), mem_file);
        if(write_result == 0)
        {
            printf("[ERROR] Cannot write string %s to /proc/[pid]/mem file\n", argv[3]);
            return 11;
        }
    }


    // close files
    fclose(maps_file);
    fclose(mem_file);
    return 0;
}

char* find_string(char* string, long string_length, const char* substring) 
{
    int substring_length = strlen(substring);
    for(long i=0; i<string_length; i++) 
    {
        if(string[i] == substring[0])
        {
            bool is_same = true;
            for(int j=0; j<substring_length; j++) 
            {
                if(string[i+j] != substring[j])
                {
                    is_same = false;
                }
            }
            if(is_same == true) 
            {
                return string+i;
            }
        }
    }
    return NULL;
}

//gcc -Wall -Wextra -pedantic -Werror 0001_read_write_heap.c -o 0001_read_write_heap.out
//
// debug
// gcc -g -Wall -Wextra -pedantic -Werror 0001_read_write_heap.c -o 0001_read_write_heap.out
// gdb --args ./0001_read_write_heap.out 439 "Holberton" "Hacking VM"