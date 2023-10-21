data segment
    first db "Enter first number: $"
    second db "Enter second number: $"
    addition db "Addition result: $"    
    subtraction db "Subtraction result: $" 
    multiplication db "Multiplication result: $"
    division db "Division result: $"
    remaindermsg db " Remainder: $"
    zeroDivMsg db "Division by zero$"
    andmsg db "AND result: $"
    ormsg db "OR result: $" 
    xormsg db "XOR result: $"
    not1msg db "First number NOT result: $"
    not2msg db "Second number NOT result: $"
    overflowmsg db "Addition overflow detected", 13, 10, '$'
    mulOverflow db "Multipication overflow detected$"
    remainder db 6 dup(0)
    res db 6 dup(0)
    mulRes db 11 dup(0)
    newline db  13, 10, '$'   
    num1buf db 6
         db ?
         db 6 dup(0)
    num2buf db 6
         db ?
         db 6 dup(0)
    num1 dw 0
    num2 dw 0
ends

code segment
start:
    mov ax, data
    mov ds, ax
    mov es, ax
    
    lea dx, first
    call output
    
    lea dx, num1buf
    call input
    
    lea dx, newline
    call output
    
    mov ax, 0
    lea bx, num1buf + 2
    call checkNeg
    lea si, num1
    mov [si], ax
    
    lea dx, second
    call output
    
    lea dx, num2buf
    call input
    
    lea dx, newline
    call output
    
    mov ax, 0
    lea bx, num2buf + 2 
    call checkNeg
    lea di, num2
    mov [di], ax
       
    mov si, [num1]
    mov di, [num2]
    add si, di
    call checkOverflow
    
    lea dx, addition
    call output
    
    mov ax, si 
    lea di, res 
    call convertToStr
    mov dx, di       
    call output 
    
    lea dx, newline
    call output
    
    mov si, [num1]
    mov di, [num2]
    sub si, di
    
    lea dx, subtraction
    call output
    
    mov ax, si 
    lea di, res
    call convertToStr
    mov dx, di
    call output
    
    lea dx, newline 
    call output
    
    lea dx, multiplication
    call output
    
    mov ax, [num1]
    mov di, [num2]
    mul di
    mov si, dx
    
    lea di, mulRes
    call checkMul
    
    
    lea dx, newline
    call output
    
    lea dx, division
    call output
    
    mov dx, 0
    mov ax, [num1]
    mov di, [num2]
    call divide
    
    lea dx, newline
    call output
    
    lea dx, andmsg
    call output
    
    mov ax, [num1]
    mov di, [num2]
    and ax, di
    
    lea di, res
    call convertToStr
    mov dx, di
    call output
    
    lea dx, newline
    call output
    
    lea dx, ormsg
    call output
    
    mov ax, [num1]
    mov di, [num2]
    or ax, di
    
    lea di, res
    call convertToStr
    mov dx, di
    call output
    
    lea dx, newline
    call output
    
    lea dx, xormsg
    call output
    
    mov ax, [num1]
    mov di, [num2]
    xor ax, di
    
    lea di, res
    call convertToStr
    mov dx, di
    call output
    
    lea dx, newline
    call output
    
    lea dx, not1msg
    call output
    
    mov ax, [num1]
    not ax
    
    lea di, res
    call convertToStr
    mov dx, di
    call output 
    
    lea dx, newline
    call output
    
    lea dx, not2msg
    call output
    
    mov ax, [num2]
    not ax
    
    lea di, res
    call convertToStr
    mov dx, di
    call output
    
    mov ax, 4c00h
    int 21h 

checkNeg:
    cmp [bx], '-'
    je negative
    call convertToNum
    ret
negative:
    inc bx
    call convertToNum
    neg ax
    ret
    
nonnegative:    
    call convertToNum 

divide:
    test di, di
    jz zero
    div di
    mov cx, dx
    
    lea di, res
    call convertToStr
    mov dx, di
    call output
    
    lea dx, remaindermsg
    call output
    
    mov ax, cx
    lea di, remainder
    call convertToStr
    mov dx, di
    call output
    
    ret
zero:
    lea dx, zeroDivMsg
    call output
    ret
    
checkOverflow:
    jc overflow
    ret
overflow:
    mov ah, 09h
    lea dx, overflowmsg
    int 21h
    ret
 
convertToNum:   
    cmp byte ptr [bx], '$'
    je endConversionNum

    sub byte ptr [bx], '0'
    add al, byte ptr [bx]

    inc bx

    cmp byte ptr [bx], '$'
    je endConversionNum 
    
    mov dx, 10
    mul dx
    jmp convertToNum

endConversionNum:
    ret 
    
convertToStr:
    mov bx, 10
    add di, 5         
    mov byte ptr [di], '$'

convert_loop:
    dec di           
    mov dx, 0       
    div bx           
    add dl, '0'     
    mov [di], dl     

    test ax, ax      
    jnz convert_loop 
    ret
       
output:
    mov ah, 09h
    int 21h
    ret  

checkMul:
    jo moverflow 
    call convertToStr
    mov dx, di
    call output
    ret            
    
moverflow:
    lea dx, mulOverflow
    call output 
    ret  
       
input:
    mov ah, 0Ah
    int 21h 
    mov ax, 0
    mov si, dx  
    add si, 1
    mov al, [si]
    add si, 1       
    add si, ax        
    mov byte ptr [si], '$'
    ret
        
ends

end start
