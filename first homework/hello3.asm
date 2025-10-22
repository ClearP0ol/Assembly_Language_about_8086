.model small
.stack 64
.data
hello db "Hello World25",0dh,0ah,'$'
.code
start:
    mov ax,@data
    mov ds,ax
    mov dx,offset hello
    mov ah,9
    int 21h
    mov ax,4c00h
    int 21h
end start