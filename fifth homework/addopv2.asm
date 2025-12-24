.model small
.stack 100h
.data
    prompt1    db 'input first number: $'
    prompt2    db 0dh, 0ah, 'input second number: $'
    echo_msg   db ' -> echo: $'
    msg_result db 0dh, 0ah, 'result = $'
    msg_ovf    db 0dh, 0ah, 'Error: Signed Overflow!$'

    val1       dw 0
    sign1      db 0
    val2       dw 0
    sign2      db 0

    ovf_flag   db 0           ; ★新增：由 INT 4 ISR 置 1 表示溢出

.code
start:
    mov ax, @data
    mov ds, ax

    ; ======================================================
    ; ★新增：重写 INT 4 向量，让 INTO 触发我们自己的 ISR
    ; ======================================================
    call install_int4

    ; --- 1. 读取并回显第一个数 ---
    lea dx, prompt1
    mov ah, 09h
    int 21h
    call read_and_echo
    mov val1, ax
    mov sign1, bl

    ; --- 2. 读取并回显第二个数 ---
    lea dx, prompt2
    mov ah, 09h
    int 21h
    call read_and_echo
    mov val2, ax
    mov sign2, bl

    ; ==========================================
    ; === 有符号加法与溢出处理（无 JO/JNO）===
    ; ==========================================

    ; 步骤 1: 将第一个数转换为有符号补码形式
    mov ax, val1
    cmp sign1, 1
    jne load_second
    neg ax

load_second:
    ; 步骤 2: 将第二个数转换为有符号补码形式，存入 BX
    mov bx, val2
    cmp sign2, 1
    jne do_addition
    neg bx

do_addition:
    ; ★每次运算前清溢出标志变量
    mov ovf_flag, 0

    ; 步骤 3: 执行加法（CPU 会设置 OF）
    add ax, bx

    ; ★关键替换：不用 jo/jno，改用 INTO
    ; 若 OF=1 -> 触发 INT 4 -> ISR 把 ovf_flag 置 1
    into

    ; ★通过变量判断是否溢出（这里用 JE/JNE，不是 JO/JNO）
    cmp ovf_flag, 1
    je  handle_overflow

    ; --- 如果没有溢出，输出结果 ---
    push ax
    lea dx, msg_result
    mov ah, 09h
    int 21h
    pop ax

    test ax, ax
    jns print_positive

    ; 如果是负数
    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax
    neg ax

print_positive:
    call print_val
    jmp prog_exit

handle_overflow:
    lea dx, msg_ovf
    mov ah, 09h
    int 21h

prog_exit:
    mov ax, 4c00h
    int 21h


; ======================================================
; ★新增：安装 INT 4 向量（0000:0010）
; ======================================================
install_int4 proc
    push ax
    push es
    cli
    xor ax, ax
    mov es, ax
    mov word ptr es:[4*4], offset int4_isr  ; IP
    mov word ptr es:[4*4+2], cs             ; CS
    sti
    pop es
    pop ax
    ret
install_int4 endp


; ======================================================
; ★新增：INT 4 中断服务程序（由 INTO 触发）
; 功能：把 ovf_flag 置 1，然后 IRET
; ======================================================
int4_isr proc far
    push ax
    push ds
    mov ax, @data
    mov ds, ax
    mov ovf_flag, 1
    pop ds
    pop ax
    iret
int4_isr endp


; ======================================================
; 子程序：读取输入 -> 记录符号 -> 立即回显
; 出口参数：AX = 绝对值, BL = 符号(1负, 0正)
; ======================================================
read_and_echo proc
    push cx
    push dx

    xor bx, bx
    mov cl, 0

    mov ah, 01h
    int 21h
    cmp al, '-'
    jne is_digit
    mov cl, 1
    jmp start_read

is_digit:
    cmp al, 0dh
    je  echo_now
    sub al, '0'
    mov ah, 0
    mov bx, ax

start_read:
    mov ah, 01h
    int 21h
    cmp al, 0dh
    je  echo_now

    sub al, '0'
    mov ah, 0
    push ax

    mov ax, bx
    mov dx, 10
    mul dx
    pop dx
    add ax, dx
    mov bx, ax
    jmp start_read

echo_now:
    push bx
    lea dx, echo_msg
    mov ah, 09h
    int 21h

    cmp cl, 1
    jne only_num
    mov dl, '-'
    mov ah, 02h
    int 21h

only_num:
    pop bx
    mov ax, bx
    call print_val

    mov ax, bx
    mov bl, cl

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
