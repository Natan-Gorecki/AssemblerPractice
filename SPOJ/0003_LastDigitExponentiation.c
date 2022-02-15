#include <stdlib.h>
#include <stdio.h>

char last_digit_exponentiation(int a, int b) 
{
    char last_digit = a % 10;
    if(last_digit == 0)
        return 0;
    if(last_digit == 1)
        return 1;
    if(last_digit == 5)
        return 5;
    if(last_digit == 6)
        return 6;

    if(last_digit == 2) 
    {
        char remainder = b % 4;
        switch(remainder) 
        {
        case 0:
            return 6;
        case 1:
            return 2;
        case 2:
            return 4;
        case 3:
            return 8;
        }
    }

    if(last_digit == 3) 
    {
        char remainder = b % 4;
        switch(remainder) 
        {
        case 0:
            return 1;
        case 1:
            return 3;
        case 2:
            return 9;
        case 3:
            return 7;
        }
    }

    if(last_digit == 4) 
    {
        char remainder = b % 2;
        switch(remainder) 
        {
        case 0:
            return 6;
        case 1:
            return 4;
        }
    }

    if(last_digit == 7) 
    {
        char remainder = b % 4;
        switch(remainder) 
        {
        case 0:
            return 1;
        case 1:
            return 7;
        case 2:
            return 9;
        case 3:
            return 3;
        }
    }

    if(last_digit == 8) 
    {
        char remainder = b % 4;
        switch(remainder) 
        {
        case 0:
            return 6;
        case 1:
            return 8;
        case 2:
            return 4;
        case 3:
            return 2;
        }
    }

    if(last_digit == 9) 
    {
        char remainder = b % 2;
        switch(remainder) 
        {
        case 0:
            return 1;
        case 1:
            return 9;
        }
    }
}

int main() 
{
    char D; // 1≤D≤30 
    scanf("%hhd", &D);     
    while(D--) 
    {
        int a, b; // 1 ≤ a,b ≤ 1 000 000 000
        scanf("%d %d", &a, &b);
        char last_digit = last_digit_exponentiation(a, b);
        printf("%hhd\n", last_digit);
    }
    return 0;
}