#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <stdarg.h>

void log(FILE* file, const char* format, ...) {
    time_t currentTime;
    time(&currentTime);
    struct tm* timeInfo = localtime(&currentTime);
    char timeString[9];
    strftime(timeString, sizeof(timeString), "%H.%M.%S", timeInfo);
    fprintf(file, "[%s]: ", timeString);

    va_list args;
    va_start(args, format);
    vfprintf(file, format, args);
    va_end(args);

    fprintf(file, "\n");
}

int main() {
    int startTime = 0;
    int endTime = 0;
    int dur = 0;
    int key = 0; // 1 - f1, 2 - d, 3 - c, 4 - r, 5 - e
    short color = 0;
    short n = 0, m = 0, row = 0, column = 0;
    char buffer[2000];

    FILE *file = fopen("logs.txt", "w");

    if (file == NULL) {
        printf("Failed to open logs.txt\n");
        return 0;
    }

    while (1) {
    wait_keys:    
        asm {
            mov ah, 01h        
            int 16h            

            jz wait_keys       
            
            mov ah, 00h        
            int 16h            

            cmp al, 's'        
            je key_s_pressed 
        
            cmp ah, 3Bh
            je F1_pressed
            
            jmp wait_keys      
        }
        F1_pressed:
        asm {
            mov word ptr key, 1
            jmp end_check
        }     
        key_s_pressed:
        asm {
            mov ah, 0 
            int 1ah
            mov startTime, dx
            
            call is_key_pressed
            jmp end_check 
        }
        asm {
        is_key_pressed proc
            mov ah, 00h          
            int 16h 

            cmp al, 'd'
            je d_pressed
            
            cmp al, 'c'
            je c_pressed
            
            cmp al, 'r'
            je r_pressed
            
            cmp al, 'e'
            je e_pressed
            
            ret
        }
        d_pressed:
        asm {
            mov ah, 0 
            int 1ah
            mov endTime, dx
            
            mov ax, endTime
            sub ax, startTime
            mov dur, ax
            
            mov word ptr key, 2
            ret
        }
        c_pressed:
        asm {
            mov word ptr key, 3
            ret
        }
        r_pressed:
        asm {
            mov word ptr key, 4
            ret
        }
        e_pressed:
        asm {
            mov word ptr key, 5
            ret
        is_key_pressed endp
    }
    end_check:

        char buff[6];
        char durMsg[] = "Duration: $";
        char newl[3] = {(char)10, (char)13, '$'};
        char text1[] = "Macro list:$";
        char text2[] = "S + D: Make a sound with the duration of pressing$";
        char text3[] = "S + C: Change text and background color$";
        char text4[] = "S + R: Starts rotating text in console$";
        char text5[] = "S + E: Exit$";

        if (!key) {
            goto wait_keys;
        } else if (key == 1) { 
            log(file, "'F1' pressed");
            asm {
                mov ah, 09h
                lea dx, text1
                int 21h   
                
                lea dx, newl
                int 21h

                lea dx, text2
                int 21h 

                lea dx, newl
                int 21h

                lea dx, text3
                int 21h 

                lea dx, newl
                int 21h

                lea dx, text4
                int 21h 

                lea dx, newl
                int 21h

                lea dx, text5
                int 21h 

                lea dx, newl
                int 21h

                cmp byte ptr color, 0
                jne skip
                mov byte ptr color, 7
            }
        skip:
            asm {
                call colorize
                jmp wait_keys
            }
        } else if (key == 2) {
            log(file, "'s + d' pressed. Duration of sound: %d tics", dur);
            asm {                
                mov ah, 09h
                lea dx, durMsg
                int 21h

                mov ax, dur    
                lea di, buff
                call convertToStr
                    
                mov ah, 09h
                mov dx, di
                int 21h
                    
                mov ah, 09h
                lea dx, newl
                int 21h
                    
                mov si, dur
                mov ax, 40
                mul si
                mov si, ax
            }
            generate_sound:
            asm {
                in al, 61h
                or al, 2
                out 61h, al

                call delay

                in al, 61h
                and al, 11111100b
                out 61h, al

                call delay
                
                dec si
                cmp si, 0
                jg generate_sound
            }              
        } else if (key == 3) {
            log(file, "'s + c' pressed. Color: %d", color);
            asm {
                inc color
                call colorize
            }
        } else if (key == 4) {
            log(file, "'s + r' pressed");
            asm {
                call rotate
            }
        } else if (key == 5) {
            log(file, "'s + e' pressed. Terminating program...");
            return 0;
        }
        if (!color) {
            color = 7;
        }
        asm {
            call colorize
        }
        key = 0;
    }
    fclose(file); 
    return 0;
asm {
convertToStr proc
    mov bx, 10
    add di, 5         
    mov byte ptr [di], '$'
}
convert_loop:
asm {
    dec di           
    mov dx, 0       
    div bx           
    add dl, '0'     
    mov byte ptr [di], dl     

    test ax, ax      
    jnz convert_loop 
    ret
convertToStr endp
}
asm {
delay proc
    mov cx, 65535
}
_wait:
asm {
    loop _wait
    ret
delay endp

colorize proc
    mov ah, 03h
    mov bh, 0 
    int 10h

    mov byte ptr n, dh
    mov byte ptr m, dl
    
    mov byte ptr row, 0
    mov byte ptr column, 0
}  
color_loop:
asm {
    mov ah, 02h    
    mov bh, 0     
    mov dh, byte ptr row     
    mov dl, byte ptr column    
    int 10h
    
    mov ah, 08h
    mov bh, 0
    int 10h 
    
    mov ah, 09h
    mov bh, 0
    mov bl, byte ptr color
    mov cx, 1
    int 10h
    
    inc byte ptr column
    cmp byte ptr column, 80
    jge __next_row       

    jmp color_loop
}
__next_row:
asm {
    inc byte ptr row
    mov byte ptr column, 0
    cmp byte ptr row, 25
    jl color_loop
    
    mov ah, 02h    
    mov bh, 0     
    mov dh, byte ptr n     
    mov dl, byte ptr m    
    int 10h
    
    ret
colorize endp
}
asm {
rotate proc
    mov ah, 03h
    mov bh, 0 
    int 10h

    mov byte ptr n, dh
    mov byte ptr m, dl
}    
main_loop:
asm {
    lea si, buffer
    mov byte ptr row, 0
    mov byte ptr column, 0
}    
read_loop:
asm {
    mov ah, 02h    
    mov bh, 0     
    mov dh, byte ptr row     
    mov dl, byte ptr column    
    int 10h
    
    mov ah, 08h
    mov bh, 0
    int 10h 
    
    mov byte ptr [si], al
    inc si 
    
    inc byte ptr column
    cmp byte ptr column, 80
    jge next_row       

    jmp read_loop
}
next_row:
asm {
    inc byte ptr row
    mov byte ptr column, 0
    cmp byte ptr row, 25
    jge end_read
    jmp read_loop
}  
end_read:
asm {
    lea si, buffer
    mov byte ptr row, 0
    mov byte ptr column, 1
    
    mov di, 0
}  
print_loop:
asm {
    mov ah, 02h    
    mov bh, 0
    mov dh, byte ptr row     
    mov dl, byte ptr column    
    int 10h
    
    mov ah, 09h
    mov bh, 0
    mov bl, byte ptr color
    mov cx, 1
    mov al, byte ptr [si]
    int 10h        
    inc si
    inc di 
    
    inc byte ptr column
    cmp byte ptr column, 80
    jge _next_row

    jmp print_loop
}
_next_row:
asm {
    cmp di, 80
    jl wt
    inc byte ptr row
    mov byte ptr column, 1
    cmp byte ptr row, 25
    jge end_print
    jmp print_loop
}
wt:
asm { 
    mov ah, 02h    
    mov bh, 0     
    mov dh, byte ptr row     
    mov dl, 0    
    int 10h
    
    mov ah, 09h
    mov bh, 0
    mov bl, byte ptr color
    mov cx, 1
    mov al, byte ptr [si]
    int 10h        
    inc si
    
    mov di, 0
    inc byte ptr row
    mov byte ptr column, 1
    cmp byte ptr row, 25
    jge end_print
    jmp print_loop
}   
end_print:    
asm { 
    mov ah, 01h        
    int 16h            

    jnz _exit
    
    call delay
    call delay
    call delay
    call delay
    call delay
    call delay
    jmp main_loop
}
_exit:
asm {
    mov ah, 02h    
    mov bh, 0     
    mov dh, byte ptr n     
    mov dl, byte ptr m    
    int 10h
    ret
rotate endp
}
}

