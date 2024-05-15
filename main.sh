#!/bin/bash
. ./app_starter.sh
. ./groups_service.sh

echo "Добро пожаловать в скрипт контактной информации и учета студентов!"

start
command_number=-1

while [[ $command_number -ne 0 ]]
do
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
            echo "Нажмите любую кнопку, чтобы продолжить"
            read -s -n 1
            ;;
        2)
            work_with_one_group
            ;;
        3)
            create_group
            echo "Нажмите любую кнопку, чтобы продолжить"
            read -s -n 1
            ;;
        4)
            delete_group
            echo "Нажмите любую кнопку, чтобы продолжить"
            read -s -n 1
            ;;
        0)
            ;;
        *)
            echo "Неизвестный номер команды! Повторите попытку"
            echo "Нажмите любую кнопку, чтобы продолжить"
            read -s -n 1
            command_number=-1
            ;;
    esac
    echo -e "\n"
done

echo "Работа программы завершена!"
