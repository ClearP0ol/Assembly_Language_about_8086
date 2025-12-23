DATA SEGMENT
    ; 将原本的大写字母改为小写
    prompt      db 'input n (1-100): $'
    result_msg  db 0dh, 0ah, 'the sum (1+2+...+n) is: $'
    n_val       dw 0
    sum_val     dw 0
DATA ENDS

STACK SEGMENT STACK
    dw 100h dup(?)
STACK ENDS

CODE SEGMENT
    assume cs:code, ds:data, ss:stack

START:
    mov ax, data
    mov ds, ax

    ; 1. 显示提示 (已改为小写)
    lea dx, prompt
    mov ah, 09h
    int 21h

    ; 2. 读取输入并转为数字
    mov bx, 0
READ_CHAR:
    mov ah, 01h
    int 21h
    cmp al, 0dh     ; 回车键
    je  DO_CALC
    sub al, '0'
    mov ah, 0
    mov cx, ax
    mov ax, bx
    mov dx, 10
    mul dx
    add ax, cx
    mov bx, ax
    jmp READ_CHAR

DO_CALC:
    mov n_val, bx
    
    ; 3. 核心计算逻辑
    mov cx, bx      
    mov ax, 0       
    jcxz SHOW_RES   
SUM_LOOP:
    add ax, cx      
    loop SUM_LOOP   
    mov sum_val, ax 

    ; 4. 显示结果提示语 (已改为小写)
SHOW_RES:
    lea dx, result_msg
    mov ah, 09h
    int 21h

    ; 5. 十进制输出结果
    mov ax, sum_val
    mov bx, 10
    mov cx, 0
SPLIT:
    mov dx, 0
    div bx          
    push dx         
    inc cx
    cmp ax, 0
    jne SPLIT

PRINT_SUM:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop PRINT_SUM

    ; 6. 退出程序
    mov ax, 4c00h
    int 21h

CODE ENDS
END START