#!/bin/bash

# this file is for creating a col in table logic
# we should get the cur_table and ask the user for :
# 1. the name of the col
# 2. the datatype of the col
## then after that add the col to the meta file of the table
# for more info refer to the table_structure.txt file

if [ "$is_connected" != "true" ]; then
    echo "ERROR: no db connection"
    exit
fi
add_col() {

    if [ -f "$dbms_dir"/"$cur_db"/"$cur_table.meta" ]; then
        read -p "enter the col name" col_name
        echo "choose col data type : "
        select option in "int" "float" "varchar" "date"; do
            case $REPLY in
            1)
                echo "$col_name:int" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
                break
                ;;
            2)
                echo "$col_name:float" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
                break
                ;;
            3)
                read -p "enter the size of var char" var_char || var_char=45

                echo "$col_name:varchar:$var_char" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
                break
                ;;
            4)
                echo "$col_name:date" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
                break
                ;;
            esac
        done
    else
        echo "meta data file not found adding meta data file"
        touch "$dbms_dir"/"$cur_db"/"$cur_table.meta"
        add_col
    fi
}

add_col
