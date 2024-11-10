.model tiny
.stack 100h
.data
    size equ 7
    str db '<number>'
    enter_string db 'Enter a string:', 0Dh, 0Ah, '$' 
    is_number db 1
    is_was_dot db 0
    number_before_dot db 0
    start_word dw 0
    count_word db 0
    buffer db 200, ?, 200 dup('$')
.code
main:
    ; enter string
    mov ah, 09h
    lea dx, enter_string
    int 21h
    
    mov ah, 0Ah
    lea dx, buffer
    int 21h 
     
    lea si, buffer + 2
    mov start_word, si
    
    lea ax, buffer
    
iterate:
    lodsb                     
    cmp al, 0Dh              
    je end_iterate  ;exit      
    cmp al, ' '        ;space
    jne start_of_word 
    jmp iterate     
    
                                      
start_of_word:
    mov is_was_dot, 0
    mov number_before_dot, 0          ;set si on begin of string
    mov is_number, 1
    dec si
    mov start_word, si
    lodsb
    cmp al, '-'
    je if_minus
    dec si
    jmp iterate_in_word
if_minus:
    cmp [si], ' '
    je not_digit_word
    cmp [si], 0Dh
    je not_digit_word
    mov number_before_dot, 0
    jmp iterate_in_word
    
iterate_in_word:
    lodsb
    cmp al, ' '
    je end_of_word
    cmp al, '.'
    je dot
    cmp al, 0Dh
    je end_of_string
    cmp al, '0'         ;number check
    jb not_digit_word     
    cmp al, '9'
    ja not_digit_word
    mov number_before_dot, 1
    jmp iterate_in_word 

dot:
    add is_was_dot, 1
    cmp is_was_dot, 1
    jne set_not_correct
    cmp number_before_dot, 0
    je set_not_correct
    jmp iterate_in_word 
set_not_correct:
    mov is_number, 0
    jmp iterate_in_word    

not_digit_word:               ;set is_number false
    mov is_number, 0
    jmp iterate_in_word                 

end_of_word:                ;to the next word
    cmp is_number, 0
    je iterate 
    mov si, start_word
    jmp replace_digits

end_of_string:              ;end check string
    cmp is_number, 0
    je end_iterate 
    mov si, start_word
    jmp replace_digits_end

replace_digits_end:         ;replace last number 
    lodsb
    cmp al, 0Dh
    je end_iterate
    mov byte ptr [si-1], 1                            
    jmp replace_digits_end

replace_digits:             ;replace numbers
    lodsb
    cmp al, ' '
    je iterate
    mov byte ptr [si-1], 1                            
    jmp replace_digits    

end_iterate:
    
    lea si, buffer + 2
    
iterate_del:             ;delete same symbols
    lodsb
    cmp al, 0Dh
    je end_del
    cmp [si], 1
    jne iterate_del
    cmp al, 1
    jne iterate_del
    dec si
    mov bx, 0
    jmp del
        
del:
    cmp [si+bx], 0Dh
    je iterate_del
    
    mov al, [si+bx+1]
    mov [si+bx], al
    
    inc bx
    jmp del        
 
end_del:
    
    lea si, buffer + 2
get_count:                    ;get count of numbers in string
    lodsb
    cmp al, 0Dh
    je replace
    cmp al, 1
    jne skip_char
    inc count_word
skip_char:
    jmp get_count
    
replace:
    cmp count_word, 0
    je print_string                 ;algorithm insert <number>
    dec count_word       
    lea si, buffer+2
    jmp find_end
    
find_end:    
    lodsb 
    cmp al, 0Dh
    jne find_end
    dec si
    
    mov bx, 0
    lea di, si+size
    jmp iterate_insert

insert:                       ; insert <number>
    lea di, si-bx
    lea si, str
    mov cx, size+1
    rep movsb
    cmp count_word, 0
    je print_string
    jmp replace
    
iterate_insert:              ;increasing the insertion space
    lea ax, buffer
    add ax, 2
    cmp ax, si+bx
    ja print_string
    cmp [si+bx], 1
    je insert

    mov ax, [si+bx]
    mov [di+bx], ax
    dec bx
    jmp iterate_insert
        

print_string:
    mov ah, 02h         
    mov dl, 0Dh         
    int 21h
    
    mov dl, 0Ah         
    int 21h
                       ;print string
    lea si, buffer+2

print_char:
    lodsb          
    cmp al, 0Dh     
    je end_program     

    mov ah, 0Eh       
    int 10h        
    jmp print_char    

end_program:
    mov ah, 4Ch       
    int 21h 
end main
