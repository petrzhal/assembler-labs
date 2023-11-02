.model small

data segment
    resMsg db "Result: $"
    cMsg db "Target length: $"
    nameMsg db "File name: $"
    fMsg db "File content: $"
    nl db 10, 13, '$'
    file_name db 32 dup(0)
    file dw ?    
    buff db 255 dup(0) 
    resBuff db 6 dup(0)     
ends

code segment
    newl macro 
    lea dx, ds:nl
    mov ah, 09h
    int 21h
endm 
    
start:
    mov ax, @data
    mov ds, ax
    
    mov si, 82h
    lea di, ds:file_name
 
file_loop:
    mov al, byte ptr es:[si]
    cmp al, ' '
    je endf
    mov byte ptr ds:[di], al
    inc si
    inc di
    jmp file_loop
    
endf:
    inc si
    inc di
    mov byte ptr ds:[di], '$'
    
    lea dx, ds:cMsg
    mov ah, 09h
    int 21h
     
    xor dx, dx
    xor ax, ax
      
num_loop:   
    cmp byte ptr es:[si], 0Dh
    je endConversionNum
    
    mov cx, ax
    mov ah, 02h
    mov dl, byte ptr es:[si]
    int 21h 
    mov ax, cx
    
    sub byte ptr es:[si], '0'
    add al, byte ptr es:[si]

    inc si

    cmp byte ptr es:[si], 0Dh
    je endConversionNum 
    
    mov dx, 10
    mul dx
    jmp num_loop

endConversionNum:
    mov di, ax
    
    mov ah, 3Dh
    mov al, 0
    lea dx, ds:file_name 
    int 21h
    mov ds:[file], ax
    
    mov ah, 3Fh
    lea dx, ds:buff
    mov cx, 255
    mov bx, ds:[file]
    int 21h 
    mov bx, ax   
    mov ds:[buff + bx], '$'

    lea si, ds:buff
    
    newl
    
    lea dx, ds:nameMsg
    mov ah, 09h
    int 21h
    
    lea dx, ds:file_name
    int 21h
    
    newl
    
    lea dx, ds:fMsg
    int 21h
    
    newl      
    
    mov dx, si
    int 21h
    
    xor bx, bx 
main_loop:
    xor cx, cx
     
    
str_loop:
    mov al, byte ptr ds:[si]
    cmp al, 0Dh
    je next_str
    cmp al, 0
    je eof     
    inc cx
    inc si 
    jmp str_loop
    
next_str:
    add si, 2
    cmp cx, di
    jle main_loop    
    inc bx
    jmp main_loop
    
eof:
    cmp cx, di
    jle end_main
    inc bx
    jmp end_main
    
end_main:
    newl
            
    mov ah, 09h
    lea dx, ds:resMsg
    int 21h
    
    mov ax, bx
    lea di, ds:resBuff
    jmp convertToStr
back:   
    mov ah, 09h
    lea dx, di
    int 21h
    
    mov ax, 4c00h 
    int 21h
    
convertToStr:
    mov bx, 10
    add di, 5         
    mov byte ptr ds:[di], '$'

convert_loop:
    dec di           
    mov dx, 0       
    div bx           
    add dl, '0'     
    mov ds:[di], dl     

    test ax, ax      
    jnz convert_loop 
    jmp back 
ends

end start
