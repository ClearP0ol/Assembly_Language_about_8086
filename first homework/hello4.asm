.model small
.stack 64
.data
hello db "hello World",0dh,0ah,'$'
.code
start:
    mov ax,@data
    mov ds,ax
    lea dx,hello
    mov ah,9
    int 21h
    mov ax,4c00h
    int 21h
end start