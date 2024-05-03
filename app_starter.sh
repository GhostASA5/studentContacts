#!/bin/bash

data_folder=data
groups_db_name=$data_folder/groups.json

function start () {

    if ! command -v jq &> /dev/null; 
    then
        echo "Ошибка: jq не найден. Пожалуйста, установите jq перед выполнением этого скрипта."
        echo "Чтобы установить jq через терминал на Ubuntu пропишите: sudo apt-get install jq"
        exit 1
    fi

    if [[ ! -d  $data_folder ]]
    then
        mkdir $data_folder
    fi

    if [[ ! -f $groups_db_name ]]
    then
        touch $groups_db_name
        echo "[]" >> $groups_db_name
    fi
}
