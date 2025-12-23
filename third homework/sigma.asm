.model small
.stack 64
.data
    sum dw 0
.code
start:
    mov ax,@data
    mov ds,ax
    mov cx,100
    for_loop:
        add sum,cx
        loop for_loop
    mov ax,sum
    call print_num
    mov ax,4c00h
    int 21h
print_num proc near
    push ax
    push bx
    push cx
    push dx
    mov bx,10
    mov cx,0
next_digit:
    xor dx,dx
    div bx
    push dx
    inc cx
    cmp ax,0
    jne next_digit
print_loop:
    pop dx
    add dl,48
    mov ah,02h
    int 21h
    loop print_loop
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp
end start