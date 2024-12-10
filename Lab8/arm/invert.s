.global _start

.section .data
input_string:
    .asciz "Enter string to invert:\n"

.section .bss
    .lcomm buffer, 1024

.section .text
_start:
    LDR r0, =input_string
    BL print_string

    MOV r0, #0      
    LDR r1, =buffer    
    MOV r2, #1024 
    MOV r7, #3      
    SVC 0          


    LDR r0, =buffer  
    BL invert_case   

    LDR r0, =buffer 
    BL print_string    

    MOV r7, #1       
    SVC 0          

invert_case:
    LDRB r1, [r0]   
    CMP r1, #0         
    BEQ end_invert   


    CMP r1, #'A'
    BLT next_char
    CMP r1, #'Z'
    BGT next_char

    ADD r1, r1, #'a' - 'A' 
    B store_char

next_char:
    CMP r1, #'a'
    BLT store_char
    CMP r1, #'z'
    BGT store_char

    SUB r1, r1, #'a' - 'A'  

store_char:
    STRB r1, [r0]     
    ADD r0, r0, #1   
    B invert_case    

end_invert:
    BX lr           

print_string:
    MOV r1, r0       
    MOV r2, #1024    
    MOV r7, #4         
    MOV r0, #1    
    SVC 0             
    BX lr          

