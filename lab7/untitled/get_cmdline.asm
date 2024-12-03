%macro print 1
    push rax
    push rdi
    push rsi
    push rdx
    push rcx

    mov rax, 1              ; системный вызов sys_write
    mov rdi, 1              ; файловый дескриптор 1 (stdout)
    mov rsi, %1             ; указатель на строку
    mov rdx, 1024
    syscall

    pop rcx
    pop rdx
    pop rsi
    pop rdi
    pop rax
%endmacro


section .data
    prefix db '/proc/', 0
    suffix db '/cmdline', 0
    buffer times 1024 db 0            ; буфер для чтения содержимого файла   
    msg db 'a', 0Ah, 0Dh, 0 
    file_path times 1024 db 0 
    filename times 1024 db 0
    f db '1', 0

section .bss
    file_desc resb 1
    

section .text
    global get_cmdline

get_cmdline:
    mov rbx, rdi
    
    lea rsi, [rel filename]  
    lea rdi, [rel prefix]    
    call strcpy
    mov rdi, rbx     
    call strcpy
    
    lea rdi, [rel suffix]   
    call strcpy

    ; Открыть файл
    mov rax, 2                        ; системный вызов sys_open
    lea rdi, [rel filename]           ; имя файла (с относительным адресом)
    mov rsi, 0                        ; режим чтения
    syscall
    mov rbx, rax                      ; сохранить файловый дескриптор                   

    ; Читать содержимое файла
    mov rax, 0                        ; системный вызов sys_read
    mov rdi, rbx                      ; файловый дескриптор
    lea rsi, [rel buffer]             ; буфер для чтения (с относительным адресом)
    mov rdx, 1024                     ; количество байт для чтения
    syscall

    ; Закрыть файл
    mov rdi, rbx
    mov eax, 3
    syscall


    ; Найти первый пробел и завершить строку
    mov rdi, buffer
    mov rsi, file_path
    

find_space:
    mov al, [rdi]
    cmp al, ' '
    je end_string
    cmp al, 0
    je end_string
    mov [rsi], al
    inc rdi
    inc rsi
    jmp find_space
end_string:
    mov byte [rsi], 0               ; Добавить нулевой байт


    lea rax, [rel file_path]
    ret


strcpy:
    .copy_next:
        mov al, [rdi]
        mov [rsi], al
        test al, al
        je .done
        inc rsi
        inc rdi
        jmp .copy_next
    .done:
        ret
