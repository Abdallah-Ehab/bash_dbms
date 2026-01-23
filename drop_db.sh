#!/bin/bash


#this file is for the code for droppping the db aka : just deleting the db_dir

# we need to handle these edge cases 
# 1- what if the deleted db doesn't exist 
# 2- what if I drop the current dp -> I should disconnect 
# 3- what if I'm not disconnected to a db -> dropping should ask you for the name of the db
# 4- 3 has a relationship to one -> I can't drop non existent db unless I'm not connected to any db
# variables needed : $dbms_dir -> main.sh, $db_name -> connect_to_db.sh

#check if we are connected
if [ "$is_connected" = "true" ]; then
    echo "Drop current database '$cur_db'? [y/n]"
    read -r option
    
    if [[ "$option" =~ ^[yY]$ ]]; then
        if [ -d "$dbms_dir/$cur_db" ]; then  
            rm -rf "$dbms_dir/$cur_db"
            echo "Database '$cur_db' dropped"
            #disconnect from the cur_db
            # Todo: make this a helper function
            cur_db=""
            is_connected=false
        else
            echo "ERROR: Database directory not found"
        fi
    else
        echo "Drop cancelled"
    fi
else 
    read -p "Enter database name to drop: " rem_db_name
    
    if [ -d "$dbms_dir/$rem_db_name" ]; then
        echo "Drop '$rem_db_name'? [y/n]"
        read -r option
        
        if [[ "$option" =~ ^[yY]$ ]]; then
            rm -rf "$dbms_dir/$rem_db_name"
            echo "Database '$rem_db_name' dropped"
        else
            echo "Drop cancelled"
        fi
    else
        echo "ERROR: Database '$rem_db_name' does not exist"
    fi
fi