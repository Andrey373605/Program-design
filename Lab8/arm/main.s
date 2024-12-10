.global main
main:
    STR LR, [SP, #-16]!       

    LDR X0, =a
    LDR X1, =b
    LDR X2, =c
    LDR D0, [X0]              
    LDR D1, [X1]          
    LDR D2, [X2]        

    // D = b^2 - 4ac
    FMUL D3, D1, D1            // D3 = b^2
    FMOV D4, 4.0               // D4 = 4
    FMUL D4, D4, D0            // D4 = 4a
    FMUL D4, D4, D2            // D4 = 4ac
    FSUB D5, D3, D4            // D5 = b^2 - 4ac

    // x1 и x2
    FSQRT D5, D5               // D5 = sqrt(D)
    FNEG D6, D1                // D6 = -b
    FSUB D7, D6, D5            // D7 = -b - sqrt(D)
    FADD D8, D6, D5            // D8 = -b + sqrt(D)
    FDIV D7, D7, D0            // x1 = (-b - sqrt(D)) / a
    FDIV D8, D8, D0            // x2 = (-b + sqrt(D)) / a
    FMOV D9, 2.0               // D9 = 2
    
    FDIV D0, D7, D9            // x1 = x1 / 2
    LDR X0, =fmt               
    BL printf                

    FDIV D0, D8, D9            // x2 = x2 / 2
    LDR X0, =fmt        
    BL printf           


    MOV X0, #0
    BL exit
    LDR LR, [SP], #16        
    RET

.data
a: .double 1.0            
b: .double -3.0              
c: .double 2.0             
fmt: .asciz "root = %e\n"     

