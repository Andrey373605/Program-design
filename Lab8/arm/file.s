.include "macros.s"             // подключаем макросы
 
.global main
main:

    print enterNameMesage 16
    mov x0, #0 
    ldr x1, =filename1 
    mov x2, #2048
    mov x8, #63
    svc 0

    ldr x0, =filename1       
    mov x1, #256             
replace_newline1:
    ldrb w2, [x0], #1     
    cmp w2, #10          
    beq replace_zero1     
    cmp w2, #0            
    beq end_replace1     
    b replace_newline1
replace_zero1:
    strb wzr, [x0, #-1]   
    b replace_newline1     
end_replace1:

    
    print enterNameMesage 16
    mov x0, #0 
    ldr x1, =filename2 
    mov x2, #256
    mov x8, #63
    svc 0 

    ldr x0, =filename2       
    mov x1, #256             
replace_newline2:
    ldrb w2, [x0], #1     
    cmp w2, #10          
    beq replace_zero2     
    cmp w2, #0            
    beq end_replace2     
    b replace_newline2
replace_zero2:
    strb wzr, [x0, #-1]   
    b replace_newline2     
end_replace2:



    openFile filename1, S_RDWR
    MOV X11, X0
    CMP X0, 0         

    openFile filename2, O_CREAT
    MOV X12, X0
    CMP X0, 0         
  
copy_file: 
    MOV X0, X11      
    MOV X1, 0
    MOV X2, X12
    MOV X3, 0
    MOV X4, -1
    MOV X5, 0
    MOV X8, #285          
    SVC 0

    CMP X0, 0         
    BGE no_error

error:
    mov x1, x0 
    ldr x0, =err_msg              
    bl printf 
    
    exit 0

no_error:
 
    print successMesage 16    
    
    close X11
    close X12

    openFile filename2, O_RDONLY
    MOV X11, X0  
    B.PL read           
    print errMessage 21    
    B finish              
read: 
    readFile X11, output, 2048   
    close X11
    close X12                
    print output 2048           
 
finish:    
    exit 0        
.data
    err_msg: .asciz "Error code: %d\n"
    errMessage: .asciz "Fail\n" 
    successMesage: .asciz "Copy success\n"
    enterNameMesage: .asciz "Enter file name:\n"   
    output: .fill 2048, 1, 0
.bss
    filename1: .skip 256
    filename2: .skip 256
               
