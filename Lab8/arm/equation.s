.global main
main:
    STR LR, [SP, #-16]! 

    LDR X0, =start_str       
    BL printf      

    // Подготовка стека для хранения значений
    LDR X0, =fmt_input         // Формат для scanf
    LDR X1, =a                 // Адрес переменной a
    LDR X2, =b                 // Адрес переменной b
    LDR X3, =c                 // Адрес переменной c
    BL scanf                   // Ввод значений a, b, c

    LDR X0, =a
    LDR D0, [X0]              // Загружаем значение a
    LDR X1, =b
    LDR D1, [X1]              // Загружаем значение b
    LDR X2, =c
    LDR D2, [X2]              // Загружаем значение c

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
    BL printf                  // Вывод x1

    FDIV D0, D8, D9            // x2 = x2 / 2
    LDR X0, =fmt        
    BL printf                  // Вывод x2

    MOV X0, #0
    BL exit
    LDR LR, [SP], #16        
    RET


.data
a: .double 0.0            
b: .double 0.0              
c: .double 0.0             
fmt: .asciz "root = %e\n"     
fmt_input: .asciz "%lf %lf %lf" 
start_str: .asciz "enter a b c separated by space\n"

