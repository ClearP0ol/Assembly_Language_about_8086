.model small
.stack 64
.data
.code
start:
    mov ax,@data
    mov ds,ax
    mov cx,13
    mov ah,02h
    nxt_alpha_1:
        mov dl,78
        sub dl,cl
        int 21h
        mov dl,' '
        int 21h
        dec cx
        cmp cx,0
        jne nxt_alpha_1
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
    mov cx,13
    nxt_alpha_2:
        mov dl,91
        sub dl,cl
        int 21h
        mov dl,' '
        int 21h
        dec cx
        cmp cx,0
        jne nxt_alpha_2
    mov ax,4c00h
    int 21h
    
end start