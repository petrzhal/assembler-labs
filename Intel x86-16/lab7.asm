.model small
.data
    EPB dw 0
    cmd_off dw offset commLine
    cmd_seg dw ?
    fcb1 dd 0
    fcb2 dd 0
    Len dw $-EPB
    commLine db 0, ' ', 126 dup(0), '$' 
    programName db "lab6.exe", 0
    path db "params.txt", 0
    file dw 0
    content db 128 dup(0)
    rsErr db "An error occurred while resizing", 10, 13, '$'
    stErr db "An error occurred while starting program", 10, 13, '$'
    openErr db "An error occurred while opening file", 10, 13, '$'
    readErr db "An error occurred while reading file", 10, 13, '$'
    DataSize = $ - EPB
    
.stack 100h
.code
start:
    mov ax, @data
    mov ds, ax
    mov cmd_seg, ax
    
    mov ah, 3Dh
    mov al, 0
    lea dx, path
    int 21h
    
    jc errOpenFile
    
    mov [file], ax
    
    mov ah, 3Fh
    lea dx, content
    mov cx, 128
    mov bx, [file]
    int 21h
    
    jc errReadFile
    
    mov bx, ax
    mov byte ptr [commLine], bl
    
    lea si, content
    lea di, commLine + 2

parse_loop:
    mov al, byte ptr [si]
    cmp al, 0Dh
    je next_par
    cmp al, 0
    je end_file
    mov byte ptr [di], al
    inc di
    inc si
    jmp parse_loop
    
next_par:
    mov byte ptr [di], ' '
    add si, 2
    inc di
    jmp parse_loop

end_file:
    mov byte ptr [di], 0Dh
    
    mov ax, 4A00h 
    mov bx, ((CodeSize / 16) + 17) + ((DataSize / 16) + 17) + 1
    int 21h
    
    jc errResize
    
    mov ax, @data
    mov es, ax    
    
    mov ah, 4Bh
    mov al, 00h 
    
    mov dx, offset programName
    mov bx, offset EPB
    int 21h
    
    jc errStart
    
    mov ax, 4C00h
    int 21h

errOpenFile:
    mov ah, 09h
    lea dx, openErr
    int 21h

errReadFile:
    mov ah, 09h
    lea dx, readErr
    int 21h
    
errResize:
    mov ah, 09h
    lea dx, rsErr
    int 21h
    
errStart:
    mov ah, 09h
    lea dx, stErr
    int 21h
CodeSize = $ - start
end start
