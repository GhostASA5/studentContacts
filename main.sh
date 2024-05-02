#!/bin/bash
. ./app_starter.sh
. ./groups_service.sh

echo "Добро пожаловать в скрипт контактной информации и учета студентов!"

start
command_number=-1

while [[ $command_number -ne 0 ]]
do
    echo -e "\n"
    read -p "Вы находитесь в главном меню. Выберите команду:
1 - вывести список всех групп
2 - начать работу с определенной группой
3 - добавить новую группу
4 - удалить группу
0 - выход
" command_number

    case $command_number in
        1)
            get_groups_list
            ;;
        2)
            read -p "Введите номер группы: " code
            work_with_one_group $code
            ;;
        3)
            read -p "Введите код новой группы: " code
            read -p "Введите название специализации новой группы: " specialization
            create_group $code $specialization
            ;;
        4)
            read -p "Введите код группы, которую хотите удалить: " code
            delete_group $code
            ;;
        0)
            ;;
        *)
            echo "Неизвестный номер команды! Повторите попытку"
            command_number=-1
            ;;
    esac
done

echo "Работа программы завершена!"
