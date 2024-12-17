.section .data
input_string: .asciz "Enter string to invert:\n"

.section .bss
    .lcomm buffer, 1024

.section .text
.global _start
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
    LDRB r1, [r0]        // Загрузить текущий байт
    CMP r1, #0
    BEQ end_invert       // Если байт == 0 (конец строки), выйти

    CMP r1, #0xD0        // Проверка первого байта для русского символа
    BEQ check_second_byte
    CMP r1, #0xD1        // Проверка второго диапазона
    BEQ check_second_byte

    // Если это не русская буква, обработать как латиницу
    CMP r1, #'A'
    BLT store_char
    CMP r1, #'Z'
    BLE convert_to_lower_en

    CMP r1, #'a'
    BLT store_char
    CMP r1, #'z'
    BLE convert_to_upper_en

store_char:
    STRB r1, [r0]        // Сохранить байт
    ADD r0, r0, #1       // Перейти к следующему
    B invert_case

check_second_byte:
    LDRB r2, [r0, #1]   
    LDRB r1, [r0]
    CMP r1, #0xD0        // Для первого диапазона
    BEQ check_upper_ruD0
    CMP r1, #0xD1        // Для второго диапазона
    BEQ check_upper_ruD1
    B store_char

check_upper_ruD0:
    CMP r2, #0x90        // '<A'
    BLT store_char

    CMP r2, #0x9F        // 'А-П'
    BLE convert_to_lower_ru

    CMP r2, #0xAF        // 'Р-Я'
    BLE convert_to_lower_ru1

    CMP r2, #0xBF        // 'а-п'
    BLE convert_to_upper_ru

    B store_char

check_upper_ruD1:
    CMP r2, #0x80        // '<р'
    BLT store_char
    CMP r2, #0x8F        // 'р-я'
    BLE convert_to_upper_ru1
    
    B store_char

convert_to_lower_ru1:
    LDRB r3, [r0]       // Загружаем первый байт (старший байт) символа
    ADD r3, r3, #1      // Прибавляем 1 к первому байту
    STRB r3, [r0]       // Записываем измененный первый байт обратно
    SUB r2, r2, #0x20    // Преобразовать в нижний регистр
    STRB r2, [r0, #1]
    ADD r0, r0, #2       // Перейти к следующему символу
    B invert_case

convert_to_lower_ru:
    ADD r2, r2, #0x20    // Преобразовать в нижний регистр
    STRB r2, [r0, #1]
    ADD r0, r0, #2       // Перейти к следующему символу
    B invert_case

convert_to_upper_ru1:
    LDRB r3, [r0]       // Загружаем первый байт (старший байт) символа
    SUB r3, r3, #1      // Прибавляем 1 к первому байту
    STRB r3, [r0]       // Записываем измененный первый байт обратно
    ADD r2, r2, #0x20    // Преобразовать в верхний регистр
    STRB r2, [r0, #1]
    ADD r0, r0, #2       // Перейти к следующему символу
    B invert_case

convert_to_upper_ru:
    SUB r2, r2, #0x20    // Преобразовать в верхний регистр
    STRB r2, [r0, #1]
    ADD r0, r0, #2       // Перейти к следующему символу
    B invert_case

convert_to_lower_en:
    ADD r1, r1, #'a' - 'A' // Преобразовать в нижний регистр
    B store_char

convert_to_upper_en:
    SUB r1, r1, #'a' - 'A' // Преобразовать в верхний регистр
    B store_char

end_invert:
    BX lr                 // Вернуться из функции


print_string:
    MOV r1, r0
    MOV r2, #1024
    MOV r7, #4
    MOV r0, #1
    SVC 0
    BX lr
