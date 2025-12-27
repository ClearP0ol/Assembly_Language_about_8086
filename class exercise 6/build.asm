; ===== BUILD.ASM =====
public build_table
extrn years:byte, incomes:dword, staffs:word
extrn table:byte

code segment
assume cs:code

build_table proc far
    push ds
    push es
    push si
    push di
    push bx
    push cx
    push dx
    push ax

    ; 初始化段寄存器
    mov ax, seg years
    mov ds, ax
    mov ax, seg table
    mov es, ax

    xor si, si      ; si 用于 years 和 incomes (都是4字节步长)
    xor di, di      ; di 用于 table (16字节步长)
    xor bx, bx      ; bx 用于 staffs (2字节步长)
    mov cx, 21      ; 处理 21 年的数据

next_row:
    ; 1. 复制年份 (4 字节)
    mov ax, word ptr years[si]
    mov es:[di], ax
    mov ax, word ptr years[si+2]
    mov es:[di+2], ax

    ; 2. 复制收入 (dword, 4 字节) -> table[di+5]
    mov ax, word ptr incomes[si]     ; 低16位
    mov es:[di+5], ax
    mov ax, word ptr incomes[si+2]   ; 高16位
    mov es:[di+7], ax

    ; 3. 复制雇员数 (word, 2 字节) -> table[di+0Ah]
    mov ax, staffs[bx]
    mov es:[di+0Ah], ax

    ; 4. 计算人均收入 (Income / Staffs)
    ; 收入是 32 位，在 dx:ax 中
    mov ax, word ptr incomes[si]     ; 低16位入ax
    mov dx, word ptr incomes[si+2]   ; 高16位入dx
    
    ; 除以雇员数 (16位)
    ; 8086指令: div reg16 -> dx:ax / reg16
    ; 商在 ax, 余数在 dx (要求取整，直接用 ax)
    div word ptr staffs[bx]
    mov es:[di+0Dh], ax

    ; 5. 更新索引
    add si, 4       ; years 和 incomes 移动 4 字节
    add bx, 2       ; staffs 移动 2 字节
    add di, 10h     ; table 移动到下一行首 (16 字节)
    
    loop next_row

    pop ax
    pop dx
    pop cx
    pop bx
    pop di
    pop si
    pop es
    pop ds
    retf
build_table endp

code ends
end