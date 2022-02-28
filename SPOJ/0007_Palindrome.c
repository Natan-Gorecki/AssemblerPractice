#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char number[20];
char reverse_number[20];

char is_palindrome() 
{
    int first = 0;
    int last = strlen(number)-1;
    while(first<last) 
    {
        if(number[first] != number[last])
            return 0;
        first++;
        last--;
    }
    return 1;
}

void convert_to_reverse() 
{
    int j=0;
    for(int i=strlen(number)-1; i>=0; i--) 
    {
        reverse_number[j] = number[i];
        j++;
    }
}

void replace_number_with_sum() 
{
    int num1 = strtol(number, NULL, 10);
    int num2 = strtol(reverse_number, NULL, 10);
    int sum = num1 + num2;

    sprintf(number, "%d", sum);
    memset(reverse_number, '\0', 20);
}

void single_test()
{
    memset(number, '\0', 20);
    memset(reverse_number, '\0', 20);
    scanf("%s", &number);

    int count = 0;

    while(!is_palindrome(number))
    {
        convert_to_reverse(number);
        replace_number_with_sum();
        count++;
    }
    printf("%s %d\n", number, count);
}

int main() 
{
    unsigned char t; // t <= 80
    scanf("%hhu", &t);     
    while(t--) 
    {
        single_test();
    }
    return 0;
}