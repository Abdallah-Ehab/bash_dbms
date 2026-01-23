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


read -p "enter the name of the table " cur_table;

if [ -f "$dbms_dir"/"$cur_db"/"$cur_table" ]; then
    read -p "$cur_table already exists do you want ot overwrite it [Y/N]" option;
    if [[ "$option" =~ ^[Yy]$ ]]; then
        touch "$dbms_dir"/"$cur_db"/"$cur_table.meta";
        touch "$dbms_dir"/"$cur_db"/"$cur_table.txt";
    else
        echo "table create cancelled"
        exit;
    fi
    echo "table $cur_table create successfully"
else
    touch "$dbms_dir"/"$cur_db"/"$cur_table.meta";
    touch "$dbms_dir"/"$cur_db"/"$cur_table.txt";
    echo "table $cur_table create successfully";
fi
