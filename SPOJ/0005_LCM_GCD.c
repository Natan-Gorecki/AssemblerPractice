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
// Least Common Multiple
int LCM(int a, int b) 
{
    return a * b / GCD(a, b);
}
int main() 
{
    unsigned char N; // 1 ≤ N ≤ 20
    scanf("%hhu", &N);      
    while(N--) 
    {
        unsigned char a, b; // 10 ≤ a,b ≤ 30
        scanf("%hhu %hhu", &a, &b);
        printf("%d\n", LCM(a, b));
    }
    return 0;
}