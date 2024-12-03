section .data
    ; нет данных в данном примере

section .bss
    ; нет данных в данном примере

section .text
    global suspend_proc

suspend_proc:

    ; задаем сигнал SIGSTOP 
    mov rsi, 19 ; номер сигнала SIGSTOP = 19

    ; выполняем системный вызов kill
    mov rax, 62  ; номер системного вызова kill = 62
    syscall

    ret
