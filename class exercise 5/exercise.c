#include <stdio.h>
int main(){
    int a=5;
    int q=(++a)+(++a)+(++a);
    printf("%d,%d\n",a,q);
    return 0;
}