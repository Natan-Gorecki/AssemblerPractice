#include <stdlib.h>
#include <stdio.h>

double PI = 3.141592654;

int main() 
{
    double r, d;
    scanf("%lf %lf", &r, &d);      
    double area = (r*r - d*d/4) * PI;
    printf("%.2lf\n", area);
    return 0;
}