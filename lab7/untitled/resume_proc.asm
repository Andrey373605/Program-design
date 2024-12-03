section .data
    ; нет данных в данном примере

section .bss
    ; нет данных в данном примере

section .text
    global resume_proc

resume_proc:

    ; задаем сигнал SIGCONT 
    mov rsi, 18 ; номер сигнала SIGCONT = 18

    ; выполняем системный вызов kill
    mov rax, 62  ; номер системного вызова kill = 62
    syscall

    ret
