#include <iostream> 
#include <cstring>  

using namespace std;
#define T_SIZE 1001  

char* string_merge(char*, char*);

int main()
{
    int t, n;
    char S1[T_SIZE], S2[T_SIZE], * S;
    cin >> t; /* wczytaj liczbę testów */
    cin.getline(S1, T_SIZE);
    while (t)
    {
        cin.getline(S1, T_SIZE, ' ');
        cin.getline(S2, T_SIZE);
        S = string_merge(S1, S2);
        cout << S << endl;
        delete[] S;
        t--;
    }
    return 0;
}

char* string_merge(char* str1, char* str2)
{
    int len1 = strlen(str1), len2 = strlen(str2);
    int length = len1 >= len2 ? len2 : len1;

    char* str = new char[length * 2 + 1];
    for (int i = 0; i < length; i++)
    {
        str[2*i] = str1[i];
        str[2 * i + 1] = str2[i];
    }
    str[length * 2] = '\0';

    return str;
}