.model tiny
.data 
    str db '<number>'
    buffer db '  1', 0Dh, 0Ah, '$$$$$$$$$$$$$$$$$'

.code
main:
    mov ah, 02h
    mov dx, 7h
    int 21h
end main
