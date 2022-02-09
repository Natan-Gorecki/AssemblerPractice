#include <stdlib.h>
#include <stdio.h>

void print_last_numbers(int n)
{
    if(n <= 1) 
    {
        printf("0 1\n");
        return;
    }

    if(n>=10) 
    {
        printf("0 0\n");
        return;
    }

    switch(n) 
    {
    case 2:
        printf("0 2\n");
        break;
    case 3:
        printf("0 6\n");
        break;
    case 4:
        printf("2 4\n");
        break;
    case 5:
        printf("2 0\n");
        break;
    case 6:
        printf("2 0\n");
        break;
    case 7:
        printf("4 0\n");
        break;
    case 8:
        printf("2 0\n");
        break;
    case 9:
        printf("8 0\n");
        break;
    }
}
int main() 
{
    char D; // 1≤D≤30 
    scanf("%hhd", &D);    
    while(D--) 
    {
        int n; // 0 ≤ n ≤ 1 000 000 000
        scanf("%d", &n);
        print_last_numbers(n);
    }
    return 0;
}