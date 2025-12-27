#include <stdio.h>

/**
 * 模拟汇编中的子程序 (print_num proc)
 * 原理：在 C 语言中，函数调用会自动处理寄存器的保存与恢复。
 * 编译器会通过“函数栈帧（Stack Frame）”来保护调用者的环境。
 */
void print_num(int n) {
    // 对应汇编中的 push ax, bx, cx, dx
    // C 语言编译器会自动在内存栈中为局部变量分配空间
    printf("%d", n);
    // 函数返回时，对应 pop dx, cx, bx, ax 和 ret
}

int main() {
    printf("The 9mul9 table:\n");

    // 外层循环：对应 row_loop (使用 cx 控制)
    for (int i = 9; i >= 1; i--) {
        
        // 内层循环：对应 col_loop (使用 bx 从 1 增加到 i)
        for (int j = 1; j <= i; j++) {
            
            // 1. 打印被乘数 (i)
            print_num(i);
            
            // 2. 打印乘号 (*)
            printf("*");
            
            // 3. 打印乘数 (j)
            print_num(j);
            
            // 4. 打印等号 (=)
            printf("=");
            
            // 5. 计算并打印结果 (i * j)
            // 对应汇编中的 mul bl
            print_num(i * j);
            
            // 6. 打印间隔空格
            printf("  ");
        }
        
        // 每一行结束换行：对应汇编中的 0dh, 0ah
        printf("\n");
    }

    return 0;
}