name "calc"

PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

org 100h
jmp start


msg1 db "enter first number: $"
msg2 db "enter the operator:    +  -  *  /     : $"
msg3 db "enter second number: $"
msg4 db  0dh,0ah , 'the approximate result of my calculations is : $' 
err1 db  "wrong operator!", 0Dh,0Ah , '$'
smth db  " and something.... $"  
msg5 db "overflow$"
msg6 db "dividing by zero$"
ten dw 10
make_minus DB ?  

opr db '?'

num1 dd ?
num2 dd ?


start:


    lea dx, msg1
    mov ah, 09h    ; output string at ds:dx
    int 21h  

    call scan_num
    mov num1, cx 


    putc 0Dh
    putc 0Ah


    lea dx, msg2
    mov ah, 09h     
    int 21h  


    mov ah, 1   
    int 21h
    mov opr, al


    putc 0Dh
    putc 0Ah


    cmp opr, 'q'      ; q - exit in the middle.
    je exit

    cmp opr, '*'
    jb wrong_opr
    cmp opr, '/'
    ja wrong_opr

    lea dx, msg3
    mov ah, 09h
    int 21h  

    call scan_num
    mov num2, cx 


    lea dx, msg4
    mov ah, 09h     
    int 21h  


    cmp opr, '+'
    je do_plus

    cmp opr, '-'
    je do_minus

    cmp opr, '*'
    je do_mult

    cmp opr, '/'
    je do_div


wrong_opr:
    lea dx, err1
    mov ah, 09h     ; output string at ds:dx
    int 21h  

exit:
    ret 


do_plus:
    mov ax, num1
    add ax, num2
    jc overflow_message
    jo overflow_message
    call print_num    ; print ax value.
    jmp exit

do_minus:
    mov ax, num1
    sub ax, num2
    jc overflow_message
    jo overflow_message
    call print_num    ; print ax value.
    jmp exit

do_mult:
    mov ax, num1
    imul num2 ; (dx ax) = ax * num2.
    jc overflow_message
    jo overflow_message 
    call print_num    ; print ax value.
    jmp exit

do_div:
    cmp num2, 0
    je zero_div
    mov dx, 0
    mov ax, num1
    idiv num2  ; ax = (dx ax) / num2.
    cmp dx, 0
    jnz approx
    jc overflow_message
    jo overflow_message
    call print_num    ; print ax value.
    jmp exit
approx:
    call print_num    ; print ax value.
    lea dx, smth
    mov ah, 09h    ; output string at ds:dx
    int 21h  
    jmp exit 
    

overflow_message:
    lea dx, msg5
    mov ah, 09h    ; output string at ds:dx
    int 21h
    jmp exit
    
zero_div:
    lea dx, msg6
    mov ah, 09h    
    int 21h
    jmp exit         


SCAN_NUM PROC NEAR
    push dx
    push ax
    push si
        
    mov cx, 0
    mov cs:make_minus, 0

next_digit:
    mov ah, 00h ;scan from keyboeard
    int 16h     ; write to al

    mov ah, 0Eh ;print
    int 10h

    cmp al, '-'
    je set_minus

    cmp al, 0Dh ;cr
    jne not_cr
    jmp stop_input
        
not_cr:
    cmp al, 08h ;back
    jne backspace_checked
        
    mov dx, 0
    mov ax, cx 
    div cs:ten 
    mov cx, ax
    PUTC ' '
    PUTC 08h ;back  
    jmp next_digit
        
backspace_checked:
    cmp al, '0'             ;check 0-9
    jb remove_not_digit
        
    cmp al, '9'
    ja remove_not_digit
    jmp ok_digit
      
remove_not_digit:       
    PUTC 08h     ;remove digit
    PUTC ' '
    PUTC 08h             
    jmp next_digit 
             
ok_digit:
    push ax
    mov ax, cx
    mul cs:ten   ;result in dx|ax
    mov cx, ax
    pop ax

    cmp dx, 0   
    jne too_big

    sub al, '0'
    mov ah, 0     ;save only lower part
    mov dx, cx    ;reserve copy
    add cx, ax 
    jc too_big2
    jmp next_digit

set_minus:
    mov cs:make_minus, 1
    jmp next_digit

too_big2:
    mov cx, dx      ; restore cx from dx
    MOV dx, 0
too_big:
    mov ax, cx
    div cs:ten  ; save in ax
    mov cx, ax
    PUTC 08h ;back
    PUTC ' '
    PUTC 08h ;back       
    jmp next_digit
               
stop_input:
    cmp cs:make_minus, 0
    je not_minus
    neg cx
not_minus:
    pop si
    pop ax
    pop dx
    ret
SCAN_NUM ENDP


PRINT_NUM PROC NEAR
    push dx
    push ax

    cmp ax, 0
    jne not_zero

    PUTC '0'
    jmp printed

not_zero:
    cmp AX, 0
    jns positive
    neg AX
    PUTC '-'

positive:
    call PRINT_NUM_UNS
        
printed:
    pop ax
    pop dx
    ret
PRINT_NUM       ENDP



; this procedure prints out an unsigned
; number in AX (not just a single digit)
; allowed values are from 0 to 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
    push ax
    push bx
    push cx
    push dx

        ; flag to prevent printing zeros before number:
    mov cx, 1
    mov bx, 10000

    cmp ax, 0
    jz print_zero

begin_print:

        ; check divider (if zero go to end_print):
    cmp bx,0
    jz end_print

    cmp cx, 0
    je calc
    ; if AX<BX then result of DIV will be zero:
    cmp ax, bx
    jb skip
calc:
    mov cx, 0  
    mov dx, 0
    div bx      ; AX = AX / BX   (DX=remainder).

    add al, 30h    ; convert to ASCII code.
    PUTC al
    mov ax, dx  ; get remainder from last div.

skip:
    ; calculate BX=BX/10
    push ax
    mov dx, 0
    mov ax, bx
    div cs:ten
    mov bx, ax
    pop ax
    jmp begin_print
        
print_zero:
    PUTC    '0'
        
end_print:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
PRINT_NUM_UNS   ENDP

