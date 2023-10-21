.model small
.data
    buff db 200
         db ?
         db 200 dup(?)  
    words dw 50 dup(0) 
    lengths dw 50 dup(0)
    msg db "Enter a string: $"
    enter db 13, 10, "$"

.code  

start:             
    mov ax, @data
    mov ds, ax
    
    mov ah, 09h         
    mov dx, offset msg 
    int 21h     
     
    mov dx, offset buff  
    mov ah, 0Ah
    int 21h           
    
    mov ah, 09h
    mov dx, offset enter
    int 21h
             
    mov ax, 0
    mov al, buff[1]   
    mov di, offset buff[1]     
    add di, ax       
    add di, 1        
    mov [di], byte ptr '$'   
    
    mov si, offset buff[2]            
    mov bx, offset words              
    mov di, offset lengths            
    mov cx, 0
      
analyze:
    cmp byte ptr[si], ' '                
    je skip_space
    mov [bx], si
    add bx, 2
    inc cx
    mov dx, 0
    
word_length:
    cmp byte ptr[si], ' '
    je word_end
    cmp byte ptr[si], '$'
    je word_end
    inc dx
    inc si
    jmp word_length
    
word_end: 
    mov [di], dx
    add di, 2
    jmp continue
    
skip_space:
    inc si      
    
continue:
    cmp byte ptr[si], '$'
    jne analyze
    
    mov ax, 0
    
    
sort_loop:    
    mov bp, 0 
    mov cx, 0
    
outer_loop:   
    mov bx, cx            
    mov si, [words + bx] 
    mov di, [words + bx + 2] 
    
    call compare_strings
    jbe no_swap
    
    mov si, bx 
    
    mov ax, [words + si]
    xchg ax, [words + si + 2]
    mov [words + si], ax
    
    mov ax, [lengths + si]
    xchg ax, [lengths + si + 2]
    mov [lengths + si], ax   
    
    mov bp, 1
    
no_swap:
    add cx, 2
    cmp cx, di
    jl outer_loop
    
    cmp bp, 0
    jnz sort_loop
     
                        
    mov si, 0    
    mov ax, 0
    mov ah, 02h   
    
next_word:
    cmp [lengths + si], 0
    je exit
    mov di, [words + si]
    mov bx, [lengths + si] 
    
output:
    mov dl, byte ptr[di]
    int 21h 
    inc di
    dec bx
    cmp bx, 0
    ja output
    
    add si, 2
    mov dl, byte ptr 32
    int 21h
    
    cmp bx, 0
    je next_word
   
exit:     
    mov ah, 4Ch         
    int 21h             
         
compare_strings:
    .repeat:
        mov al, [si]
        mov ah, [di]

        cmp al, ah
        jne .foundDifference
      
        cmp al, '$'
        je .endOfString
        cmp al, ' '
        je .endOfString
        
        inc di
        inc si

        jmp .repeat

    .foundDifference:   
        jb .string1IsLess
        clc  
        ret

    .string1IsLess:
        stc 
        ret

    .endOfString:
        clc 
        stc 
        ret  
      
end start  


