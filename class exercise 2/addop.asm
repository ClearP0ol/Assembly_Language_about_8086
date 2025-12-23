.model small
.stack 100h
.data
    prompt1    db 'input first number: $'
    prompt2    db 0dh, 0ah, 'input second number: $'
    echo_msg   db ' -> echo: $'
    msg_result db 0dh, 0ah, 'result = $'
    msg_ovf    db 0dh, 0ah, 'Error: Signed Overflow!$' ; 溢出报错信息

    val1       dw 0
    sign1      db 0
    val2       dw 0
    sign2      db 0

.code
start:
    mov ax, @data
    mov ds, ax

    ; --- 1. 读取并回显第一个数 ---
    lea dx, prompt1
    mov ah, 09h
    int 21h
    call read_and_echo
    mov val1, ax    ; 保存绝对值
    mov sign1, bl   ; 保存符号位

    ; --- 2. 读取并回显第二个数 ---
    lea dx, prompt2
    mov ah, 09h
    int 21h
    call read_and_echo
    mov val2, ax
    mov sign2, bl

    ; ==========================================
    ; === 有符号加法与溢出处理 ===
    ; ==========================================

    ; 步骤 1: 将第一个数转换为有符号补码形式
    mov ax, val1        ; 取出绝对值
    cmp sign1, 1        ; 检查是否标记为负数
    jne load_second     ; 如果是正数，跳过
    neg ax              ; 如果是负数，进行求补 (0 - AX)

load_second:
    ; 步骤 2: 将第二个数转换为有符号补码形式，存入 BX
    mov bx, val2
    cmp sign2, 1
    jne do_addition
    neg bx

do_addition:
    ; 步骤 3: 执行加法
    add ax, bx          ; AX = AX + BX (有符号加法)

    ; 步骤 4: 判断溢出 (Check Overflow Flag)
    ; 如果结果超出了 -32768 到 +32767 的范围，OF 标志位会被置 1
    jo  handle_overflow 

    ; --- 如果没有溢出，输出结果 ---
    push ax             ; 暂时保存计算结果
    lea dx, msg_result
    mov ah, 09h
    int 21h
    pop ax              ; 恢复结果

    ; 判断结果正负用于显示
    test ax, ax         ; 测试符号位 (SF)
    jns print_positive  ; 如果 SF=0 (非负)，直接打印

    ; 如果是负数
    push ax             ; 保存结果
    mov dl, '-'         ; 输出负号
    mov ah, 02h
    int 21h
    pop ax              ; 恢复结果
    neg ax              ; 将负数转回绝对值，以便 print_val 使用

print_positive:
    call print_val      ; 调用原本的无符号打印子程序
    jmp prog_exit

handle_overflow:
    lea dx, msg_ovf
    mov ah, 09h
    int 21h

prog_exit:
    ; 程序结束
    mov ax, 4c00h
    int 21h

; ======================================================
; 子程序：读取输入 -> 记录符号 -> 立即回显
; 出口参数：AX = 绝对值, BL = 符号(1负, 0正)
; ======================================================
read_and_echo proc
    push cx
    push dx

    xor bx, bx      ; bx 清零，用于累加绝对值
    mov cl, 0       ; cl 记录符号 (0正 1负)

    ; 步骤 A: 读取第一个字符判断符号
    mov ah, 01h
    int 21h
    cmp al, '-'     ; 判断是否是负号
    jne is_digit
    mov cl, 1       ; 记录为负数
    jmp start_read  ; 跳过负号去读数字

is_digit:
    cmp al, 0dh     ; 如果直接按回车
    je  echo_now
    sub al, '0'
    mov ah, 0
    mov bx, ax      ; 处理第一个输入的数字

start_read:
    mov ah, 01h
    int 21h
    cmp al, 0dh     ; 回车结束输入
    je  echo_now
    
    sub al, '0'
    mov ah, 0
    push ax         ; 暂时保存新读入的个位数
    
    mov ax, bx      ; 取出已有累加值
    mov dx, 10
    mul dx          ; 原值 * 10
    pop dx          ; 取出刚才压栈的个位数
    add ax, dx      ; 累加
    mov bx, ax
    jmp start_read

echo_now:
    ; 步骤 B: 立即回显
    push bx         ; 压栈备份绝对值，防止被显示子程序破坏
    lea dx, echo_msg
    mov ah, 09h
    int 21h

    cmp cl, 1       ; 如果是负数
    jne only_num
    mov dl, '-'     ; 输出负号
    mov ah, 02h
    int 21h

only_num:
    pop bx          ; 从栈里恢复绝对值
    mov ax, bx      ; 传给显示子程序
    call print_val  ; 打印绝对值
    
    ; 步骤 C: 准备返回值
    mov ax, bx      ; AX 返回绝对值
    mov bl, cl      ; BL 返回符号位
    
    pop dx
    pop cx
    ret
read_and_echo endp

; ======================================================
; 子程序：打印 AX 寄存器中的无符号数值
; ======================================================
print_val proc
    push ax
    push bx
    push cx
    push dx
    test ax, ax
    jnz split
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp p_exit
split:
    mov bx, 10
    xor cx, cx
s_l:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz s_l
p_l:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop p_l
p_exit:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_val endp

end start