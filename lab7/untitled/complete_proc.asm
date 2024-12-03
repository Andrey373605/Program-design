section .data
    ; нет данных в данном примере

section .bss
    ; нет данных в данном примере

section .text
    global complete_proc

complete_proc:

    ; задаем сигнал SIGKILL
    mov rsi, 9  ; номер сигнала SIGKILL = 9

    ; выполняем системный вызов kill
    mov rax, 62  ; номер системного вызова kill = 62
    syscall

    ret
