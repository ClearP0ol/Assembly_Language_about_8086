.model small
.stack 64
.data
msg db "Hello World25$"
.code
main proc far
    mov ax,@data
    mov ds,ax
    mov ah,9
    mov dx,offset msg
    int 21h
    mov ax,4c00h
    int 21h
main endp
    end main