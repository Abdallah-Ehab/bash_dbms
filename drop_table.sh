#!/bin/bash

#check if we are connected

read -p "Enter table name to drop: " table

if [ -f "$dbms_dir/$cur_db/$table.txt" ]; then
    echo "Are you sure , you want to Drop '$table'? [y/n]"
    read -r option
    
    if [[ "$option" =~ ^[yY]$ ]]; then
        rm -f "$dbms_dir/$cur_db/$table.txt" "$dbms_dir/$cur_db/$table.meta" 
        echo "Table dropped"
    else
        echo "Drop cancelled"
    fi
else
    echo "ERROR: table '$table' does not exist"
fi

. ./after_connection.sh