public print_table
extrn table:byte

code segment
assume cs:code

print_table proc far
    push ds
    push si
    push cx
    push ax
    push dx

    mov ax, seg table
    mov ds, ax
    xor si, si       ; table 偏移指针
    mov cx, 21       ; 21 年数据

print_loop:
    push cx          ; 保护外层循环计数

    ; 1. 打印年份 (Offset 0, 4 bytes)
    mov cx, 4
print_year:
    mov dl, [si]
    mov ah, 02h
    int 21h
    inc si
    loop print_year

    ; 打印间隔
    call print_space

    ; 2. 打印收入 (Offset 5, 4 bytes / dword)
    ; 注意：si 现在在 4，收入在 si+1 (即 5)
    mov ax, [si+1]   ; 低16位
    mov dx, [si+3]   ; 高16位
    call print_num_32

    ; 3. 打印雇员 (Offset 0Ah, 2 bytes / word)
    mov ax, [si+6]   ; si+1+5 = 0Ah
    xor dx, dx       ; 高位清零，当作32位处理
    call print_num_32

    ; 4. 打印人均收入 (Offset 0Dh, 2 bytes / word)
    mov ax, [si+9]   ; si+1+8 = 0Dh
    xor dx, dx
    call print_num_32

    ; 5. 换行
    mov ah, 02h
    mov dl, 0Dh
    int 21h
    mov dl, 0Ah
    int 21h

    ; 移动到下一行首 (每行 10H 字节)
    ; 此时 si 在 4，需要增加到 10H
    add si, 0Ch 
    
    pop cx
    loop print_loop

    pop dx
    pop ax
    pop cx
    pop si
    pop ds
    retf
print_table endp

; --- 打印 32 位无符号数并对齐 ---
; 参数: DX:AX = 数值
print_num_32 proc
    push ax
    push bx
    push cx
    push dx
    push si

    mov bx, 10
    xor cx, cx       ; 记录位数

calc_loop:
    ; 核心：32位 / 16位 除法防止溢出
    ; 公式: (High / 10) ... Remainder -> ( (Rem << 16) + Low ) / 10
    mov si, ax       ; 暂存低16位
    mov ax, dx       ; 取高16位
    xor dx, dx
    div bx           ; 高位除以10，商在ax，余数在dx
    mov bp, ax       ; 暂存高位商
    
    mov ax, si       ; 取低16位
    div bx           ; (旧余数:低16位) / 10，商在ax，余数在dx
    
    push dx          ; 保存余数（即当前位）
    inc cx
    mov dx, bp       ; 将高位商还原回dx，为下一轮做准备
    
    ; 检查 32 位商是否为 0 (DX:AX)
    or ax, dx
    jnz calc_loop

    ; 打印前置空格（为了对齐，假设每列最大10位）
    mov si, 10       ; 总宽度
    sub si, cx       ; 计算需要补的空格
    jcxz no_space    ; 防御性编程
    cmp si, 0
    jle no_space
space_loop:
    mov ah, 02h
    mov dl, ' '
    int 21h
    dec si
    jnz space_loop

no_space:
    ; 打印数字
print_digit:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digit

    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num_32 endp

print_space proc
    mov ah, 02h
    mov dl, ' '
    int 21h
    int 21h          ; 打印两个空格
    ret
print_space endp

code ends
end