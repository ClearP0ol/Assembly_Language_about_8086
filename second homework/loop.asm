.model small
.stack 64
.data
    tmp db 0
.code
start:
    mov ax,@data
    mov ds,ax
    mov cx,13
    mov ah,02h
    mov tmp,65
    for_loop:
        add [tmp],13
        sub [tmp],cx
        mov dl,[tmp]
        int 21h
        mov dl,' '
        int 21h
        loop for_loop
end start