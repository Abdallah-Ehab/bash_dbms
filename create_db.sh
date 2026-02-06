#!/bin/bash

## this script is for creating db

create_db() {
    if [ $# -eq 1 ]; then
        cur_db="$1"
    else
        read -p "Enter the name of the db: " cur_db
    fi

    if [ -d "$dbms_dir/$cur_db" ]; then
        echo "$cur_db already exists. Do you want to override? [y/n]"
        read option
        if [[ "$option" =~ ^[yY]$ ]]; then
            rm -rf "$dbms_dir/$cur_db"
            mkdir -p "$dbms_dir/$cur_db"
            echo "Database $cur_db recreated."
        else
            echo "Operation cancelled."
        fi
    else
        mkdir -p "$dbms_dir/$cur_db"
        echo "Database $cur_db created."
    fi
}

create_db "$@"
. ./dbms.sh
