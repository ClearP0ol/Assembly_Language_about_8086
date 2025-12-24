#include <stdio.h>

#include <stdio.h>

int add_with_overflow_check(int a, int b, int *overflow)
{
    int result;
    unsigned char of;

    asm volatile (
        "addl %[b], %[a]\n\t"   // a = a + b
        "seto %[of]\n\t"        // OF → of
        : [a] "+r"(a),          // 输出：a 被修改，作为 result
          [of] "=r"(of)
        : [b] "r"(b)            // 输入：b
        : "cc"                  // 条件码被修改（OF 在这里）
    );

    result = a;
    *overflow = of;
    return result;
}


int main()
{
    int ov;
    int a,b;
    printf("number1=");
    scanf("%d",&a);
    printf("number2=");
    scanf("%d",&b);
    int r = add_with_overflow_check(a, b, &ov);

    if (ov)
        printf("Error: Signed Overflow!\n");
    else
        printf("Result = %d\n", r);

    return 0;
}
