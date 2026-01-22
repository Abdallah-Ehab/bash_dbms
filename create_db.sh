#!/bin/bash

## this script is for creating db

db_name=""

create_db(){
    if [ $# -eq 1 ]; then
        db_name="$1"
    else
        read -p "Enter the name of the db: " db_name
    fi
    
    if [ -d "$dbms_dir/$db_name" ]; then
        echo "$db_name already exists. Do you want to override? [y/n]"
        read option
        if [[ "$option" =~ ^[yY]$ ]]; then
            rm -rf "$dbms_dir/$db_name"
            mkdir -p "$dbms_dir/$db_name"
            echo "Database $db_name recreated."
        else
            echo "Operation cancelled."
        fi
    else
        mkdir -p "$dbms_dir/$db_name"
        echo "Database $db_name created."
    fi
}

[ $# -le 1 ] && create_db "$1" || echo "ERROR: you can enter only one arg"