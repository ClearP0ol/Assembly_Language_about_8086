.model small
.stack 100h

.data
    ; 定义九九乘法表的数值部分，每行表示一列的数据
    table db 7,2,3,4,5,6,7,8,9           
          db 2,4,7,8,10,12,14,16,18       
          db 3,6,9,12,15,18,21,24,27
          db 4,8,12,16,7,24,28,32,36
          db 5,10,15,20,25,30,35,40,45
          db 6,12,18,24,30,7,42,48,54
          db 7,14,21,28,35,42,49,56,63
          db 8,16,24,32,40,48,56,7,72
          db 9,18,27,36,45,54,63,72,81
    info  db "x  y", 0dh, 0ah, '$'        ; 提示信息，以回车换行结尾
    space db "  ", '$'                   ; 格式调整用的空格
    err   db "  error", 0dh, 0ah, '$'     ; 错误提示信息
    endl  db 0dh, 0ah, '$'                ; 换行符

.code
start:
    mov    ax, @data        ; 初始化数据段寄存器
    mov    ds, ax
    lea    dx, info         ; 显示提示信息 "x  y"
    mov    ah, 09h          ; dos中断：显示字符串
    int    21h
    
    mov    cx, 9            ; 外循环计数器：控制行数
    mov    ax, 1            ; ax 表示乘数
    mov    si, 0            ; si 指向 table 数据的偏移量

a_loop:
    push   cx               ; 保护外循环计数器
    push   ax               ; 保护当前乘数
    mov    bx, 1            ; bx 表示被乘数，每行从 1 开始
    mov    cx, 9            ; 内循环计数器：控制列数

b_loop:
    xor    dx, dx           ; 清空 dx
    mov    dl, table[si]    ; 从表中读取“预设正确答案”
    
    ; 注意：此处 push ax 是为了保护被乘数不被 mul 破坏
    ; mul bl 执行的是 al * bl，结果存入 ax
    mul    bl               
    
    cmp    ax, dx           ; 比较【计算结果】与【表中答案】
    jne    output_err       ; 如果不相等，跳转到错误处理
    jmp    continue         ; 相等则跳过错误处理

output_err:
    ; 错误处理逻辑
    pop    dx               ; 恢复备份的 ax 值到 dx 用于显示
    push   dx               ; 重新压栈保持备份
    mov    al, dl           ; 将错误相关的数值转为字符
    add    al, 30h          ; 数字转 ascii ('0' = 30h)
    mov    ah, 02h          ; dos中断：输出单个字符
    mov    dl, al
    int    21h
    
    lea    dx, space        ; 输出空格
    mov    ah, 09h
    int    21h
    
    mov    al, bl           ; 输出当前的被乘数
    add    al, 30h
    mov    dl, al
    mov    ah, 02h
    int    21h
    
    lea    dx, err          ; 输出 " error" 字样
    mov    ah, 09h
    int    21h

continue:
    pop    ax               ; 恢复乘数 ax
    push   ax               ; 再次备份以便下次循环使用
    inc    bx               ; 被乘数 + 1
    inc    si               ; table 指针移向下一个数据
    loop   b_loop           ; 内循环 cx--

    pop    ax               ; 彻底恢复乘数 ax
    inc    ax               ; 乘数 + 1（准备下一行）
    pop    cx               ; 恢复外循环计数器 cx
    loop   a_loop           ; 外循环 cx--

    mov    ah, 4ch          ; 程序正常结束返回 dos
    int    21h

end start