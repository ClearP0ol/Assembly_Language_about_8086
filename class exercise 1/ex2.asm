data segment
    prompt  db 'please input a dec number (0-65535): $'
    result  db 0dh, 0ah, 'the hex number: $'
    num     dw 0
data ends

stack segment stack
    dw 100h dup(?)
stack ends

code segment
    assume cs:code, ds:data, ss:stack

start:
    mov ax, data
    mov ds, ax

    ; 1. 输出提示语
    lea dx, prompt
    mov ah, 09h
    int 21h

    ; 2. 读取 10 进制输入并转换为数值
    ; 原理：num = num * 10 + (input - '0')
read_dec:
    mov ah, 01h
    int 21h
    cmp al, 0dh         ; 检查是否按下回车键
    je  prep_convert
    
    sub al, '0'         ; ascii 转数值
    mov ah, 0
    mov cx, ax          ; 暂存当前输入位
    
    mov ax, num
    mov bx, 10
    mul bx              ; ax = num * 10
    add ax, cx          ; ax = num * 10 + 新输入
    mov num, ax
    jmp read_dec

prep_convert:
    ; 3. 输出结果提示
    lea dx, result
    mov ah, 09h
    int 21h

    ; 4. 核心转换逻辑：10 进制转 16 进制 (除 16 取余法)
    mov ax, num
    mov bx, 16
    xor cx, cx          ; 计数器，记录入栈位数

split_hex:
    xor dx, dx          ; 清空 dx 以进行 32/16 位除法
    div bx              ; ax / 16 -> 商在 ax, 余数在 dx
    push dx             ; 将余数入栈
    inc cx              ; 位数加 1
    cmp ax, 0           ; 商为 0 则拆分结束
    jne split_hex

    ; 5. 输出 16 进制字符
display_hex:
    pop dx              ; 从栈中弹出余数（高位先出）
    cmp dl, 9           ; 判断是数字还是字母
    jbe is_digit
    add dl, 7           ; 如果是 10-15 (a-f)，需额外加 7 跳过 ascii 断层

is_digit:
    add dl, '0'         ; 转换为 ascii 字符
    mov ah, 02h         ; dos 输出字符功能
    int 21h
    loop display_hex

exit:
    mov ax, 4c00h
    int 21h

code ends
end start