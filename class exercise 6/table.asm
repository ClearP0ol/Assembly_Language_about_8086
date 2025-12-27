public table

; 定义为 public 并指定 para(16字节)对齐，确保 seg 获取的基址准确
tableseg segment public 'data'
    ; 21行，每行16字节，初始化为0
    ; 这样定义可以确保 table 指向的是 21*16 字节连续空间的起始处
    table db 21 * 16 dup (0) 
tableseg ends

end