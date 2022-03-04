#include <stdlib.h>
#include <stdio.h>
#include <string.h>

char buffer[250];

void printf_char(char c, unsigned char count) 
{
    if(count > 2) 
    {
        printf("%c%hhu", c, count);
    }
    else if(count > 1)
    {
        printf("%c%c", c, c);
    }
    else if (count > 0)
    {
        printf("%c", c);
    }
}

void printf_compressed_text(char* text, int length)
{
    char current_char = '\0';
    unsigned char count = 0;

    for(int i=0; i<length; i++) {
        if(text[i] == '\0') 
        {
            printf_char(current_char, count);
            break;
        }
            
        if(text[i] == current_char)    
        {
            count++;
        }
        else
        { 
            printf_char(current_char, count);
                
            current_char = text[i];
            count = 1;
        }
    }
    printf("\n");
}

int main() 
{
    unsigned char C; // 1 ≤ C ≤ 50
    scanf("%hhu", &C);     
    while(C--) 
    {
        memset(buffer, '\0', 250);
        scanf("%s", &buffer); // s <= 200
        printf_compressed_text(buffer, 250);   
    }
    return 0;
}