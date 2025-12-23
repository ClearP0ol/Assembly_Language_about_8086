data segment
    prompt  db 'input hex (1-2 chars, e.g., 1F): $'
    result  db 0dh, 0ah, 'decimal: $'
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

    ; 2. 读取第一个字符
    mov ah, 01h
    int 21h
    cmp al, 0dh     ; 如果直接按回车，退出
    je exit
    
    call convert    ; 转换为数值存入 bl
    mov bh, 0
    mov num, bx     ; 存入 num

    ; 3. 读取第二个字符
    mov ah, 01h
    int 21h
    cmp al, 0dh     ; 如果第二个是回车，说明只输入了1位
    je print_res
    
    ; 如果输入了第二位，原来的第一位要 * 16
    mov cl, 4
    shl num, cl     ; num = num * 16
    
    call convert    ; 转换当前第二位字符
    add num, bx     ; 加到总和里

print_res:
    ; 4. 输出结果提示
    lea dx, result
    mov ah, 09h
    int 21h

    ; 5. 十进制拆分输出 (取余法)
    mov ax, num
    mov bx, 10
    mov cx, 0
split:
    mov dx, 0
    div bx          ; ax / 10
    push dx         ; 余数入栈
    inc cx
    cmp ax, 0
    jne split

display:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop display

exit:
    mov ax, 4c00h
    int 21h

; --- 子程序：ASCII 转数值 ---
convert proc
    cmp al, '9'
    jbe is_num
    and al, 11011111b ; 强制转大写 (针对 a-f)(将第五位变成0，相当于-32)
    sub al, 7         ; 'A' 是 65, '9' 是 57, 中间差 7 个码位
is_num:
    sub al, '0'
    mov bl, al
    ret
convert endp

code ends
end start