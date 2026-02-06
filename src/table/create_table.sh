#!/bin/bash

## this is the file for creating a table
## edgecases to handle :
# 1- what if a table with the same name exists

## how table is created :
# 1- a text file with the name the user provided is created
# 2- the user is asked to add a column
# 3- the user is asked about the data type of the column

## what will the table file look like though? :
## refer to : table_structure.txt file for more info

read -rp "enter the name of the table " cur_table

create_table() {
    touch "$dbms_dir"/"$cur_db"/"$cur_table.meta"
    touch "$dbms_dir"/"$cur_db"/"$cur_table.txt"

    declare -a col_names_arr=()

    while true; do
        read -rp "enter column name (or type 'done' to finish): " col_name

        if [ "$col_name" == "done" ]; then
            break
        fi

        col_type=""

        echo "enter data type for column $col_name: "

        select option in "int" "string"; do
            case $REPLY in
            1)
                col_type="int"
                break
                ;;
            2)
                col_type="string"
                break
                ;;
            *)
                col_type="invalid"
                echo "invalid option"
                break
                ;;
            esac
        done
        if [ "$col_type" == "invalid" ]; then
            continue
        fi
        echo "$col_name:$col_type" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
        col_names_arr+=("$col_name")
    done

    # Ask for primary key columns
    echo ""
    echo "Available columns: ${col_names_arr[*]}"
    read -rp "Enter primary key column names separated by commas (e.g. id or id,name for composite key): " pk_input

    if [ -n "$pk_input" ]; then
        echo "primary_key:$pk_input" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
    fi

    echo "Table structure for $cur_table created."
}

if [[ -f "$dbms_dir/$cur_db/$cur_table.txt" || -f "$dbms_dir/$cur_db/$cur_table.meta" ]]; then
    read -rp "$cur_table already exists do you want ot overwrite it [Y/N]:  " option
    if [[ "$option" =~ ^[Yy]$ ]]; then
        rm -f "$dbms_dir/$cur_db/$cur_table.txt" "$dbms_dir/$cur_db/$cur_table.meta"
        create_table
    else
        echo "table create cancelled"
        exit
    fi
else
    create_table
fi

. ./src/after_connection.sh
