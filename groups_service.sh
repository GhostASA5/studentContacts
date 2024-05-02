#!/bin/bash

. ./one_group_service.sh


function get_groups_list(){

    if [[ $(jq -e 'map(select(length > 0)) | length == 0' $groups_db_name) == "true" ]]
    then
        echo "Список групп пуст!"
    else
        echo "Cписок групп:"
        jq -r '.[] | .group_code + " " + .specialization' $groups_db_name
    fi
}

function work_with_one_group(){
    group_code=$1

    if ! group_exist $group_code
    then
        echo "Группы с кодом $group_code не существует!"
        return 0
    fi

    work_with_group $group_code 
}

function create_group() {
    group_code=$1
    specialization=$2

    if group_exist $group_code
    then
        echo "Группа с кодом $group_code существует!"
        return 1
    fi

    touch $data_folder/$group_code.json
    echo "[]" >> $data_folder/$group_code.json
    mkdir $data_folder/$group_code

    jq --arg group_code "$group_code" --arg specialization "$specialization" --arg file "$data_folder/$group_code.json" '. += [{ 
    "group_code": $group_code, 
    "specialization": $specialization, 
    "students_count": 0, 
    "file_location": $file }]' $groups_db_name > tmp.json && mv tmp.json $groups_db_name

    echo "Новая группа $group_code создана!"
}

# function update_group(){
#     code
# }

function delete_group(){
    group_code=$1

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