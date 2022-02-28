#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char buffer[250];
int buffer_len = 250;

void add_all_numbers() 
{
    int result = 0;
    char* pEnd;
    int number = strtol(buffer,&pEnd,10);
    result += number;

    while(*pEnd != '\0')
    {
        int number = strtol(pEnd, &pEnd, 10);
        result += number;
    }
    printf("%d\n", result);
}

void single_test()
{
    int n;
    scanf("%d", &n);
    getchar();     
    memset(buffer, '\0', 250);
    scanf("%249[^\n]", &buffer);
    getchar(); 
    add_all_numbers();
}

int main() 
{
    unsigned char t; // 0 ≤ C ≤ 100
    scanf("%hhu", &t);     
    while(t--) 
    {
        single_test();
    }
    return 0;
}