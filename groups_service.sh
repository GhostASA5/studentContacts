#!/bin/bash

. ./one_group_service.sh


function get_groups_list(){
    if [[ $(jq -e 'map(select(length > 0)) | length == 0' $groups_db_name) == "true" ]]
    then
        echo "Список групп пуст!"
    else
        echo "Cписок групп (Код группы, специализация, количество студентов):"
        jq -r '.[] | "\(.group_code), \(.specialization), \(.students_count)"' $groups_db_name
    fi
}

function work_with_one_group(){
    read -p "Введите номер группы: " group_code

    if ! group_exist $group_code
    then
        echo "Группы с кодом $group_code не существует!"
        return 0
    fi

    work_with_group $group_code 
}

function create_group() {
    read -p "Введите код новой группы: " group_code
    if group_exist $group_code
    then
        echo "Группа с кодом $group_code существует!"
        return 1
    fi
    read -p "Введите название специализации новой группы: " specialization

    touch $data_folder/$group_code.json
    echo "[]" >> $data_folder/$group_code.json
    mkdir $data_folder/$group_code

    jq --arg group_code "$group_code" --arg specialization "$specialization" '. += [{ 
    "group_code": $group_code, 
    "specialization": $specialization, 
    "students_count": 0 }]' $groups_db_name > tmp.json && mv tmp.json $groups_db_name

    echo "Новая группа $group_code создана!"
}

function delete_group(){
    read -p "Введите код группы, которую хотите удалить: " group_code

    if ! group_exist $group_code
    then 
        echo "Группы с кодом $group_code не существует!"
        return 1
    fi

    rm $data_folder/$group_code.json
    rm -r $data_folder/$group_code
    jq --arg group_code "$group_code" 'map(select(.group_code != $group_code))' $groups_db_name > tmp.json && mv tmp.json $groups_db_name
    echo "Группа с кодом $group_code удалена!"
}

function group_exist() {
    group_code=$1

    if [[ -f $data_folder/$group_code.json ]]
    then
        return 0
    else 
        return 1
    fi
}