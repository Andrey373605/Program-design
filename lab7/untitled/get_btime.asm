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
    filename db '/proc/stat', 0
    search_str db 'btime ', 0
    buffer times 4096 db 0
    newline db 10, 0
    msg db "q", 0, 0Dh, 0Ah

section .bss
    btime resb 11

section .text
    global get_btime

get_btime:
    ; Открыть файл /proc/stat
    mov rax, 2                  ; sys_open
    mov rdi, filename           ; адрес имени файла
    mov rsi, 0                  ; флаги (0 - только чтение)
    syscall

    ; Сохранить файловый дескриптор
    mov rdi, rax

    ; Прочитать содержимое файла
    mov rax, 0                  ; sys_read
    mov rsi, buffer             ; адрес буфера
    mov rdx, 4096               ; максимальное количество байт для чтения
    syscall

    ; Обработка содержимого буфера
    mov rsi, buffer
    call find_btime

    lea rax, [rel btime] 
    ret

find_btime:
    mov rcx, 4096
find_loop:
    mov al, [rsi]
    cmp al, 'b'
    je extract_btime
    inc rsi
    jmp find_loop
    ret

extract_btime:
    add rsi, 6
    mov rdi, btime
    mov rcx, 10
copy_loop:
    lodsb
    stosb
    loop copy_loop
    ret

