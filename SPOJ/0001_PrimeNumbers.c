/*
Input:
3
11
1
4

Output:
TAK
NIE
NIE
*/

#include <stdio.h>
#include <stdbool.h>

//[1..10000]
bool is_prime(short number) 
{
    if(number <= 1)
        return false;

    if(number <= 3)
        return true;

    if(number % 2 == 0 || number % 3 == 0)
        return false;
    
    for(short i=5; i*i <= number; i = i + 6)
        if(number % i == 0 || number % (i + 2) == 0)
            return false;

    return true;
}

int main() 
{
    int n; // n < 100000
    scanf("%d", &n);    
    while(n--) 
    {
        short number;
        scanf("%hd", &number);
        is_prime(number) ? printf("TAK\n") : printf("NIE\n");
    }
}