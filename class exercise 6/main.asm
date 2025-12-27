extrn build_table:far
extrn print_table:far
extrn years:byte          ; 声明外部数据，用于获取 data 段基址

stack segment
    dw 128 dup(0)
stack ends

code segment
    assume cs:code, ss:stack

start:
    ; 1. 显式初始化栈段 (SS) 和栈顶指针 (SP)
    mov ax, stack
    mov ss, ax
    mov sp, 256          ; 对应 128 dup(0) 的字节数 (128*2)

    ; 2. 初始化数据段 (DS)
    ; 指向 data.asm 中定义数据所在的段
    mov ax, seg years
    mov ds, ax

    ; 3. 调用子程序
    call build_table
    call print_table

    ; 4. 退出程序
    mov ax, 4C00h
    int 21h
code ends

end start