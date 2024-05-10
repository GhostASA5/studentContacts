#!/bin/bash

function mark_attendance() {
    group_code=$1

    if ! get_all_students $group_code > /dev/null
    then
        echo "В группе $group_code еще нет студентов."
        return 1
    fi

    echo "Для отметки присутствия студентов проставьте символы д (присутствовал) или н (не присутствовал)."

    for line in $(jq -r '.[] | .surname + "_" + .name' $data_folder/$group_code.json)
    do
        line=$(echo "$line" | tr '_' ' ')
        while true
        do
            read -p "$line: " response

            if [[ $response =~ ^[дн]$ ]]
            then
                line=$(echo "$line" | tr -d ' ')
                student_db=$data_folder/$group_code/$line.json
                today=$(date +'%Y-%m-%d')

                jq --arg date "$today" --arg is_attend "$response" '. += [{ 
                "date": $date, 
                "is_attend": $is_attend }]' $student_db > tmp.json && mv tmp.json $student_db
                break
            else
                echo "Введен не корректный символ. Повторите еще раз (д/н)."
            fi
        done
    done

    echo "Вы отметили всех студентов!"
}

function check_attendance() {
    group_code=$1

    if ! get_all_students $group_code > /dev/null
    then
        echo "В группе $group_code еще нет студентов."
        return 1
    fi

    echo "Для проверки посещаемости введите период, который хотите проверить."
    read -p "Дата начала проверки (в формате дд.мм.гггг): " start_date
    read -p "Дата окончания проверки (в формате дд.мм.гггг): " end_date

    while true
    do
        if check_date_format $start_date $end_date
        then
            break
        fi
        read -p "Дата начала проверки (в формате дд.мм.гггг): " start_date
        read -p "Дата окончания проверки (в формате дд.мм.гггг): " end_date
    done

    start_date=$(echo "$start_date" | awk -F '.' '{print $3"-"$2"-"$1}')
    end_date=$(echo "$end_date" | awk -F '.' '{print $3"-"$2"-"$1}')

    echo "Посещаемость группы $group_code (Фамилия имя процент пропусков): "

    for file in $data_folder/$group_code/*.json
    do
        student=$(echo "$file" | sed 's/.*\///')
        student=$(echo "$student" | sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g')
        student=${student%.json}

        countY=$(jq --arg start "$start_date" --arg end_date "$end_date" '[.[] | select(.date >= $start and .date <= $end_date and .is_attend == "д")] | length' "$file")
        countN=$(jq --arg start "$start_date" --arg end_date "$end_date" '[.[] | select(.date >= $start and .date <= $end_date and .is_attend == "н")] | length' "$file")

        attendance=$(echo "scale=2; $countN / ($countY + $countN) * 100" | bc)
        echo $student "$attendance %"
    done

    echo "Вы просмотрели посещаемость всех студентов."
}

function check_date_format(){
    start_date=$1
    end_date=$2

    date_regex='^[0-9]{2}\.[0-9]{2}\.[0-9]{4}$'

    if [[ ! $start_date =~ $date_regex || ! $end_date =~ $date_regex ]]
    then
        echo "Введенные даты не соответствуют формату"
        return 1
    fi

    if [[ $start_date > $end_date ]]
    then
        echo "Дата окончания проверки не может быть раньше даты начала проверки"
        return 1
    fi

    return 0
}