// inspired by https://blog.holbertonschool.com/hack-the-virtual-memory-python-bytes/

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/*
* Locates and replaces (if we have permissions) all occurences of
* an ASCII string in the entire virtual memory of a process
*
* Usage ./0002_read_write_bruteforce.out PID search_string replace_by_string
*  - PID is the pid of the target process
*  - search_string is the ASCII string you are looking to overwrite
*  - replace_by_string is the ASCII string you want to replace search_string with
*/

int initial_validation(int argc, char* argv[]);
int open_files();
int single_segment_operation();
int find_string(char* string, int string_length, const char* substring);
int fseek_safe(FILE *__stream, unsigned long __off, int __whence);


int pid;
char* search_string;
char* replace_by_string;

FILE* maps_file;
FILE* mem_file;

char maps_buffer[255];
char* addr, * perm, * offset, * device, * inode, * pathname;
char* addr_start, * addr_end;


int main(int argc, char* argv[]) 
{
    int result = initial_validation(argc, argv);
    if(result) return result;

    result = open_files();
    if(result) return result;

    while (fgets(maps_buffer, 255, maps_file))
    {
        result = single_segment_operation();
        if(result) return result;
    }

    fclose(maps_file);
    fclose(mem_file);
    return 0;
}


int initial_validation(int argc, char* argv[]) 
{
    // args validation
    if (argc != 4)
    {
        printf("Usage: %s PID search_string replace_by_string\n", argv[0]);
        return EXIT_FAILURE;
    }

    pid = atoi(argv[1]);
    if (pid <= 0)
    {
        printf("Usage: %s PID search_string replace_by_string\n", argv[0]);
        return EXIT_FAILURE;
    }

    search_string = argv[2];
    replace_by_string = argv[3];

    return EXIT_SUCCESS;
}
int open_files() 
{
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
    maps_file = fopen(maps_filename, "r");
    if (maps_file == NULL)
    {
        printf("[ERROR] Can not open file %s:\n", maps_filename);
        return EXIT_FAILURE;
    }
    mem_file = fopen(mem_filename, "rb+");
    if (maps_file == NULL)
    {
        printf("[ERROR] Can not open file %s:\n", mem_filename);
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
int single_segment_operation() 
{
    addr = strtok(maps_buffer, " ");
    perm = strtok(NULL, " ");
    offset = strtok(NULL, " ");
    device = strtok(NULL, " ");
    inode = strtok(NULL, " ");
    pathname = strtok(NULL, " \n");

    
    addr_start = strtok(addr, " -\0");
    addr_start = (char*)strtoul(addr_start, NULL, 16);
    addr_end = strtok(NULL, " -\0");
    addr_end = (char*)strtoul(addr_end, NULL, 16);
    

    // check if there is read and write permission
    if (perm[0] != 'r' || perm[1] != 'w')
    {
        printf("[*] %s does not have read/write permission\n", pathname);
        return EXIT_SUCCESS;
    }


    // read memory from mem file
    int seek_result = fseek_safe(mem_file, (unsigned long)addr_start, SEEK_SET);
    if(seek_result != 0) 
    {
        printf("[ERROR] Cannot seek to specified address %p\n", (void*)addr_start);
        return EXIT_FAILURE;
    }

    const unsigned long mem_buffer_length = (unsigned long)addr_end - (unsigned long)addr_start;
    unsigned char mem_buffer[mem_buffer_length];

    size_t read_result = fread(mem_buffer, sizeof(char), mem_buffer_length, mem_file);
    if (read_result == 0)
    {
        printf("[ERROR] Cannot read memory %s\n", pathname);
        return EXIT_FAILURE;
    }


    // find if memory segment contain string to overwrite
    int substring_offset = find_string((char*)mem_buffer, mem_buffer_length, search_string);
    if(substring_offset == -1)
    {
        printf("[*] %s doesnt contain %s\n", pathname, search_string);
        return EXIT_SUCCESS;
    }
    else
    {
        printf("[*] Found [%s]:\n", pathname);
        printf("\tpathname = %s\n", pathname);
        printf("\taddresses = %x-%x\n", (unsigned int)addr_start, (unsigned int)addr_end);
        printf("\tpermisions = %s\n", perm);
        printf("\toffset = %s\n", offset);
        printf("\tdevice = %s\n", device);
        printf("\tinode = %s\n", inode);
        printf("\taddr start [%p] | end [%p]\n", (void*)addr_start, (void*)addr_end);

        while(substring_offset != -1) 
        {
            char* substring_address = (char*)((unsigned long)addr_start + (unsigned long)substring_offset);
            printf("[*] Found %s at %p\n", search_string, (void*)substring_address);


            // seek to correct place 
            seek_result = fseek_safe(mem_file, (unsigned long)substring_address, SEEK_SET);
            if(seek_result != 0) 
            {
                printf("[ERROR] Cannot seek to specified address %p\n", (void*)substring_address);
                return EXIT_FAILURE;
            }


            // write the new string
            size_t write_result = fwrite(replace_by_string, sizeof(char), strlen(replace_by_string), mem_file);
            if(write_result == 0)
            {
                printf("[ERROR] Cannot write %s to %p\n", replace_by_string, (void*)substring_address);
                return EXIT_FAILURE;
            }
            printf("[*] Writing %s at %p\n", replace_by_string, (void*)substring_address);


            // reflect VM in buffer
            memcpy((char*)((unsigned long)mem_buffer+(unsigned long)substring_offset), replace_by_string, strlen(replace_by_string));
            substring_offset = find_string((char*)mem_buffer, mem_buffer_length, search_string);
        }
    }

    return EXIT_SUCCESS;
}
int find_string(char* string, int string_length, const char* substring) 
{
    int substring_length = strlen(substring);
    for(int offset=0; offset<string_length; offset++) 
    {
        if(string[offset] == substring[0])
        {
            bool is_same = true;
            for(int j=0; j<substring_length; j++) 
            {
                if(string[offset+j] != substring[j])
                {
                    is_same = false;
                }
            }
            if(is_same == true) 
            {
                return offset;
            }
        }
    }
    return -1;
}
int fseek_safe(FILE *__stream, unsigned long __off, int __whence) 
{
    if(__off > 2147483647 )
    {
        fseek(__stream, 2147483647, __whence);
        return fseek(__stream, (long int)(__off-2147483647), SEEK_CUR); 
    }
    else 
    {
        return fseek(__stream, (long int) __off, __whence);
    }
}

// gcc -Wall -Wextra -pedantic -Werror 0002_read_write_bruteforce.c -o 0002_read_write_bruteforce.out
//
// debug
// gcc -g -Wall -Wextra -pedantic -Werror 0002_read_write_bruteforce.c -o 0002_read_write_bruteforce.out
// gdb --args ./0002_read_write_bruteforce.out 439 "Holberton" "Hacking VM"