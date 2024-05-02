#!/bin/bash


function work_with_group(){
    group_code=$1

    command_numberr=-1

    while [[ $command_numberr -ne 0 ]]
    do
        echo -e "\n"
        read -p "Вы находитесь в меню группы $group_code. Выберите команду:
1 - вывести список всех студентов группы
2 - получить контактную информацию студента
3 - добавить студента
3 - изменить контактную информацию студента
4 - удалить студента
5 - проставить посещяемость
6 - просмотреть посещяемость
0 - закончить работу с группой 
" command_numberr

        case $command_numberr in
            1)
                get_all_students $group_code
                ;;
            2)
                get_student $group_code
                ;;
            3)
                create_student $group_code
                ;;
            4)
                read -p "Введите название группы, которую хотите удалить: " name
                
                ;;
            5)
                echo 5
                ;;
            6)
                echo 6
                ;;
            0)  
                echo "Вы возвращаетесь в главное меню!"
                return 0
                ;;
            *)
                echo "Неизвестный номер команды! Повторите попытку"
                command_numberr=-1
                ;;
        esac
    done
}

function get_all_students(){
    group_code=$1

    if [[ $(jq -e 'map(select(length > 0)) | length == 0' $data_folder/$group_code.json) == "true" ]]
    then
        echo "В этой группе еще нет ни одного студента!"
    else
        echo "Список студентов (Фамилия Имя Номер телефона): "
        jq -r '.[] | .surname + " " + .name + " " + .phone_number' $data_folder/$group_code.json
    fi
}

function get_student(){
    group_code=$1

    read -p "Введите фамилию студента: " surname
    read -p "Введите имя студента: " name

    student_file_location="$data_folder/$group_code/$surname$name.json"

    if ! student_exit $student_file_location
    then
        echo "Студент $surname $name не найден в группе $group_code!"
        return 1
    fi

    echo "Контактная информация студента: "
    jq --arg surname "$surname" --arg name "$name" '
    .[] | select(.surname == $surname and .name == $name) | .surname + " " + .name + " " + .phone_number' $data_folder/$group_code.json
}

function create_student(){
    group_code=$1

    echo "Для создания нового студента введите его данные."
    read -p "Фамилия: " surname
    read -p "Имя: " name

    student_file_location="$data_folder/$group_code/$surname$name.json"

    if student_exit $student_file_location
    then
        echo "Студент $surname $name уже находится в группе $group_code"
        return 0
    fi

    read -p "Возраст: " age
    read -p "Номер телефона: " phone_number
    read -p "Электронная почта: " email

    touch $student_file_location

    jq --arg surname "$surname" --arg name "$name" --arg age "$age" --arg phone_number "$phone_number" --arg email "$email" '. += [{ 
    "surname": $surname, 
    "name": $name,
    "age": $age, 
    "phone_number": $phone_number, 
    "email": $email }]' $data_folder/$group_code.json > tmp.json && mv tmp.json $data_folder/$group_code.json

    jq --arg group_code "$group_code" '.[] |= if .group_code == $group_code then .students_count += 1 else . end' $groups_db_name > tmp.json && mv tmp.json $groups_db_name
    
    echo "Студент $surname $name добавлен в группу!"
}

function group_exist(){
    group_code=$1

    if [[ -f $data_folder/$group_code.json ]]
    then
        return 0
    else 
        return 1
    fi
}

function student_exit(){
    student_file_location=$1

    if [[ -f $student_file_location ]]
    then
        return 0
    else 
        return 1
    fi
}