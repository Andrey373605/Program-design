#!/bin/bash

# Проверка, что передан параметр
if [ -z "$1" ]; then
  echo "Использование: $0 <name>"
  exit 1
fi

# Присвоение параметра переменной name
name=$1

aarch64-linux-gnu-gcc ${name}.s -o ${name} -static


# Проверка на ошибки сборки и связывания
if [ $? -ne 0 ]; then
  echo "Ошибка сборки или связывания ${name}"
  exit 1
else
  echo "Сборка и связывание успешны. Выполняемый файл: ./${name}"
fi



#!/bin/bash

