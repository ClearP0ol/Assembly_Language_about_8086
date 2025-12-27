#include <stdio.h>
int main(){
    for(int i=1;i<=13;i++){
        printf("%c ",'A'+i-1);
    }
    printf("\n");
    for(int i=1;i<=13;i++){
        printf("%c ",'A'+i+13-1);
    }
    return 0;
}