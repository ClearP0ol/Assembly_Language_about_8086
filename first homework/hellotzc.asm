stkseg segment stack
dw 32 dup(0)
stkseg ends

dataseg segment
    msg db "Hello World25$"
dataseg ends

codeseg segment
    assume cs:codeseg,ds:dataseg
main proc far
    mov ax,dataseg
    mov ds,ax
    mov ah,9
    mov dx,offset msg
    int 21h
    mov ax,4c00h
    int 21h
main endp
codeseg ends
end main