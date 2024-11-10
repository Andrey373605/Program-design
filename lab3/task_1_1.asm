.model tiny
.data
   str db 'Hello word!', 0Dh, '$'
   
.code 
main:
   lea dx, str
   mov ah, 09h  
   int 21h
   
   mov ah, 4Ch
   int 21h
end main      