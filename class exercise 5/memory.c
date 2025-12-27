#include <stdio.h>
#include <stdlib.h>

/* 已初始化的全局变量 —— 位于 .data 段 */
int global_init = 123;

/* 未初始化的全局变量 —— 位于 .bss 段 */
int global_uninit;

/* 函数本身 —— 位于代码段（text segment） */
void test_function(void) {
    int stack_var = 456;                 // 栈区变量
    int *heap_var = malloc(sizeof(int)); // 堆区变量

    *heap_var = 789;

    printf("======== 进程内存空间分布示例 ========\n\n");

    printf("【代码段（Text Segment）】\n");
    printf("  函数 test_function 的地址：%p\n\n", (void *)test_function);

    printf("【全局 / 静态区（Global / Static Segment）】\n");
    printf("  已初始化全局变量 global_init 地址：%p\n", (void *)&global_init);
    printf("  未初始化全局变量 global_uninit 地址：%p\n\n", (void *)&global_uninit);

    printf("【堆区（Heap Segment）】\n");
    printf("  malloc 分配的 heap_var 地址：%p\n\n", (void *)heap_var);

    printf("【栈区（Stack Segment）】\n");
    printf("  局部变量 stack_var 地址：%p\n\n", (void *)&stack_var);

    printf("=====================================\n");

    free(heap_var);
}

int main(void) {
    test_function();
    return 0;
}
