.model small
.stack 100h
.data

;lab 5 varian 15
;this program reverse all strings in file
;for start pass in cmd 1 parameter(path to file)

bias dw 0
idFile dw 0h
maxSize equ 256
bufferString db maxSize dup("$")

buff_symb db ?
db "$"
stringSize dw 0
db "$"

msgErrorOpenFile db     "Error open file", 0Ah, "$"
msgIncorrectFileName db "Incorrect file name", 0Ah, "$"
msgError db             "Some error", 0Ah, "$"
msgFileOpenComplete db  "File open correctly", 0Ah, "$"
msgDone db              "Already done", 0Ah, "$"

maxSizeCmd equ 127
fileName db maxSizeCmd dup(?)


.code

;write to console str
outPut MACRO str 
    mov  ah, 09h
    mov  dx,offset str
    int  21h
endm

;put placing position in file to t1
getPlacing MACRO bias1
    push  ax
    push  bx
    push  cx
    push  dx
    
    mov  ah, 42h
    mov  al, 1
    mov  cx, 0
    mov  dx, 0
    mov  bx, idFile
    int  21h
    jc   error
    mov  bias1, ax
    
    pop  dx
    pop  cx
    pop  bx
    pop  ax
endm         
 
 
;-----get current symbol in file (symbol on which the bias is located)----- 
getSymb proc
    push  ax
    push  bx
    push  cx
    push  dx
    
    mov  ah, 3Fh 
    mov  bx, idFile 
    lea  dx, buff_symb 
    mov  cx, 1
    int  21h
    jc   error
    
    mov  ah, 42h
    mov  al, 1
    mov  cx, -1
    mov  dx, -1
    mov  bx, idFile
    int  21h
    jc   error
    
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    
    ret
getSymb endp
;-------------------------------------------------------------

 
   
;--------------------move bias to right------------------------
movRight PROC
    push  ax
    push  bx
    push  cx
    push  dx
    
    mov  ah, 42h
    mov  al, 1
    mov  cx, 0
    mov  dx, 1
    mov  bx, idFile
    int  21h
    jc   error
    
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    
    ret 
movRight endp
;---------------------------------------------------------   
    
    
    
;--------------------move bias to left---------------------
movLeft proc
    push  ax
    push  bx
    push  cx
    push  dx

    mov  ah, 42h
    mov  al, 1
    mov  cx, -1
    mov  dx, -1
    mov  bx, idFile
    int  21h
    jc   error
    
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
movLeft endp
;------------------------------------------------------------  
 
 
  
;---------------------Get file name--------------------------
getFileName proc
    mov  si, 81h      ;in this position space
    cmp  es:[si], 0Dh
    je   errorName
    lea  di, fileName
    mov  si, 82h      ;first symbol from cmd (81h - space)
    
read_file_name:
    mov  al, es:[si]
    cmp  al, 0Dh
    je   end_file_name
    mov  [di], al
    inc  di
    inc  si
    jmp  read_file_name
    
end_file_name:
    ret     
getFileName endp
;------------------------------------------------------------
 
 
 
main:
    mov ax, @data
    mov ds, ax   
    call getFileName 
   
    ;open file
    mov ah, 3Dh
    mov al, 00000010b
    lea dx, fileName
    int 21h
    jc errorOpen
    mov idFile, ax
    
    outPut msgFileOpenComplete

;this is need for set bias in the end of file    
set_end_file:    
    mov  ah, 42h
    mov  al, 2
    mov  cx, -1
    mov  bx, idFile
    mov  dx, -1
    int  21h
    jc   error

inverse_strings:    
    mov stringSize, 0
    mov di, offset bufferString
    
l1: 
    ;write bufferString in reverse order   
    call getSymb
    cmp  buff_symb, 0Ah
    je   exit_l1
    mov  al, buff_symb
    mov  [di], al
    inc  di
    inc  stringSize
    
    call movLeft ;
    
    getPlacing bias  ;if bias is 0, then it is the biginning of the file
    cmp bias, 0
    je last
    
    
    jmp l1
exit_l1:
    call movRight
    
    ;write to file
    mov  ah, 40h
    mov  bx, idFile
    mov  cx, stringSize
    mov  dx, offset bufferString
    int  21h
    
    ;return to the previous bias
    mov  ah, 42h
    mov  al, 1
    mov  cx, -1
    mov  dx, -1
    sub  dx, stringSize
    mov  bx, idFile
    int  21h
    jc   error

;this is need for case when string is empty    
l2:
    call getSymb
    call movLeft
    cmp  buff_symb, 0Ah
    je   l2
    cmp  buff_symb, 0Dh
    je   l2    
    call movRight
    
    jmp inverse_strings
 
last:
    call getSymb
    mov  al, buff_symb
    mov  [di], al
    inc  stringSize
    
    ;write to file 
    mov  ah, 40h
    mov  bx, idFile
    mov  cx, stringSize
    mov  dx, offset bufferString
    int  21h   
     
    ;close file
    mov  ah, 3Eh
    mov  bx, idFile
    int  21h
    
    outPut msgDone 
     
    jmp  exit
    
errorOpen:
    output msgErrorOpenFile 
    jmp    exit
    
errorName:
    output msgIncorrectFileName 
    jmp    exit
    
error:
    output msgError 
    jmp    exit    
   
exit:
    mov  ah, 4Ch
    int  21h
    ret    
   
end main