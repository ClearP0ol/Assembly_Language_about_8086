; =========================
; stop_fix.asm (DOSBox, MASM+LINK, .EXE, 8086)
; Requirement: 
; 1. Use INT 16h for input (Check Shift)
; 2. Use INT 10h for output
; 3. NO INT 21h allowed
; =========================

.model small
.stack 100h

.data
    save_psp dw ?       ; 用于保存 PSP 段地址
    msg1     db 0Dh,0Ah,'[BIOS] Press keys to echo. Press SHIFT (L/R) to quit.',0Dh,0Ah,'$'

.code
start:
    ; ==========================================================
    ; 关键修复步骤 1: 保存 PSP
    ; .EXE 程序启动时，DS 和 ES 默认指向 PSP 段
    ; 我们必须在修改 DS 之前，把 PSP 段地址存起来
    ; ==========================================================
    mov bx, ds          ; 将 PSP 段地址暂存入 BX

    ; 初始化我们自己的数据段
    mov ax, @data
    mov ds, ax

    ; 将 BX 中的 PSP 地址保存到变量中，供退出时使用
    mov save_psp, bx

    ; 打印提示信息 (DS 已经指向 .data，可以正常寻址 msg1)
    lea si, msg1
    call print_dollar_str

main_loop:
    ; ------------------------------------------------
    ; 1) 检查 Shift 状态 (INT 16h, AH=02h)
    ; ------------------------------------------------
    mov ah, 02h
    int 16h
    test al, 00000011b  ; bit0=Right Shift, bit1=Left Shift
    jnz quit            ; 如果按下任意 Shift，跳转退出

    ; ------------------------------------------------
    ; 2) 检查是否有按键 (非阻塞检测) (INT 16h, AH=01h)
    ; ------------------------------------------------
    mov ah, 01h
    int 16h
    jz  main_loop       ; ZF=1 表示没按键，继续循环检测 Shift

    ; ------------------------------------------------
    ; 3) 读取按键 (INT 16h, AH=00h)
    ;    注意：前面检测到有按键后，必须用 AH=00h 把它读走，
    ;    否则缓冲区永远非空，会死循环。
    ; ------------------------------------------------
    xor ax, ax          ; AH=00h
    int 16h             ; AL=ASCII, AH=ScanCode

    ; 处理回车 (Enter) -> 换行
    cmp al, 0Dh
    jne check_extended
    
    mov al, 0Dh
    call putc
    mov al, 0Ah
    call putc
    jmp main_loop

check_extended:
    ; 处理扩展键 (如F1, 方向键等)，AL=0
    cmp al, 0
    jne print_normal
    
    ; 显示格式 [ScanCode]
    mov al, '['
    call putc
    mov al, ah          ; 扫描码在 AH
    call puthex8
    mov al, ']'
    call putc
    jmp main_loop

print_normal:
    ; 普通字符直接回显
    call putc
    jmp main_loop

quit:
    ; ==========================================================
    ; 关键修复步骤 2: 退出程序
    ; 题目禁止 INT 21h (AH=4Ch)，所以使用 INT 20h。
    ; INT 20h 指令位于 PSP 段的偏移 0 处 (PSP:0000)。
    ; 我们构造堆栈，使用 retf 跳转过去。
    ; ==========================================================
    
    mov ax, save_psp    ; 取出最开始保存的 PSP 段地址
    push ax             ; 压入段地址 (CS)
    
    xor ax, ax
    push ax             ; 压入偏移地址 0 (IP)
    
    retf                ; 远返回 -> 相当于 jmp far ptr PSP:0000 -> 执行 INT 20h

; -------------------------
; 子程序: print_dollar_str
; -------------------------
print_dollar_str proc
    push ax
    push si
.next_char:
    mov al, [si]        ; lodsb 需要处理 ds:si，这里手动取更清晰
    inc si
    cmp al, '$'
    je  .str_done
    call putc
    jmp .next_char
.str_done:
    pop si
    pop ax
    ret
print_dollar_str endp

; -------------------------
; 子程序: putc (BIOS TTY)
; -------------------------
putc proc
    push ax
    push bx
    mov ah, 0Eh
    xor bh, bh       ; 页码 0
    int 10h
    pop bx
    pop ax
    ret
putc endp

; -------------------------
; 子程序: puthex8 (打印AL的16进制)
; -------------------------
puthex8 proc
    push cx
    push bx         ; 保护 BX (后面用到 BL)
    
    mov bl, al      ; 暂存 AL
    
    ; 打印高4位
    mov al, bl
    mov cl, 4
    shr al, cl
    call putnib

    ; 打印低4位
    mov al, bl
    and al, 0Fh
    call putnib

    pop bx
    pop cx
    ret
puthex8 endp

; -------------------------
; 子程序: putnib (0-F)
; -------------------------
putnib proc
    cmp al, 9
    ja .is_alpha
    add al, '0'
    jmp .print_it
.is_alpha:
    add al, 'A' - 10
.print_it:
    call putc
    ret
putnib endp

end start