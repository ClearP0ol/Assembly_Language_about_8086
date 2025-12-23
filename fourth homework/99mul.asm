data segment
    msg db 'The 9mul9 table:', 0dh, 0ah, '$'
    space db '  $'
    equal db '*$'
    res_sym db '=$'
data ends

code segment
    assume cs:code, ds:data
start:
    mov ax, data
    mov ds, ax

    lea dx, msg
    mov ah, 09h
    int 21h

    mov cx, 9           ; 外层循环：行数 i (从9到1)
row_loop:
    push cx             ; 保存外层循环计数器
    mov bx, 1           ; 内层循环：列数 j (从1到i)
col_loop:
    ; 输出当前算式：i * j = result
    mov ax, cx
    call print_num      ; 调用过程：打印 i
    
    lea dx, equal
    mov ah, 09h
    int 21h
    
    mov ax, bx
    call print_num      ; 调用过程：打印 j
    
    lea dx, res_sym
    mov ah, 09h
    int 21h
    
    ; 计算 i * j
    mov al, cl
    mul bl              ; al = al * bl
    call print_num      ; 调用过程：打印结果
    
    lea dx, space       ; 打印空格分隔
    mov ah, 09h
    int 21h

    inc bx              ; j++
    mov al, cl
    cmp bl, al          ; 判断 j 是否超过 i
    jbe col_loop

    ; 换行
    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h

    pop cx              ; 恢复外层循环计数器
    loop row_loop

    mov ax, 4c00h
    int 21h

; --- 子程序：打印寄存器 AX 中的数字 ---
print_num proc
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx
split:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz split
show:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop show

    pop dx
    pop cx
    pop bx
    pop ax
    ret                 ; 返回主程序
print_num endp

code ends
end start