%macro print_string 1
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
    suffix db '/status', 0
    buffer times 8192 db 0            ; буфер для чтения содержимого файла   
    msg db 'a', 0Ah, 0Dh, 0 
    starttime times 20 db 0                 

section .bss
    filename resb 256        ; буфер для хранения starttime

section .text
    global get_info:

get_info:
    mov rbx, rdi

    ; Формирование строки пути к файлу
    lea rsi, [rel filename]  ; указатель на буфер для конечного пути
    lea rdi, [rel prefix]    ; указатель на префикс "/proc/"
    call strcpy
    mov rdi, rbx            ; указатель на строку с номером (PID)
    call strcpy
    lea rdi, [rel suffix]    ; указатель на суффикс "/stat"
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
    mov rdx, 8192                     ; количество байт для чтения
    syscall

    ; Закрыть файл
    mov rax, 3                        ; системный вызов sys_close
    mov rdi, rbx                      ; файловый дескриптор
    syscall

    lea rax, [rel buffer] 
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
