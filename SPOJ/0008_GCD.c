#include <stdlib.h>
#include <stdio.h>

// Greatest Common Divisor
int GCD(int a, int b)
{
    while(a != b) 
    {
        if(a > b)
            a -= b;
        else
            b -= a;
    }
    return a;
}
int main() 
{
    int N;
    scanf("%u", &N);      
    while(N--) 
    {
        int a, b; // 0 ≤ a,b ≤ 1_000_000
        scanf("%u %u", &a, &b);
        printf("%u\n", GCD(a, b));
    }
    return 0;
}