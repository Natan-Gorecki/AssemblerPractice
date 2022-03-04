#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int* array;
int arr_size;

void print_reverse_array() 
{
    for(int i=arr_size-1; i>=0; i--) 
    {
        if(i>0) 
        {
            printf("%d ", array[i]);
        }
        else
        {
            printf("%d\n", array[i]);
        }
    }
}

int main() 
{
    unsigned char t; // t <= 100
    scanf("%hhu", &t);      
    while(t--) 
    {
        scanf("%d", &arr_size);
        array = (int*)malloc(sizeof(int)*arr_size);
        for(int i=0; i<arr_size; i++) 
        {
            scanf("%d", &array[i]);
        }
        print_reverse_array();
        free(array);
    }
    return 0;
}