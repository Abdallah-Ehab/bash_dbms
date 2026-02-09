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
    if gum confirm "Drop current database '$cur_db'? This action cannot be undone."; then
        if [ -d "$dbms_dir/$cur_db" ]; then
            gum spin --spinner dot --title "Dropping database '$cur_db'..." -- rm -rf "$dbms_dir/$cur_db"
            gum style --foreground 82 "✓ Database '$cur_db' dropped successfully"
            #disconnect from the cur_db
            . ./src/helpers.sh 1
        else
            gum style --foreground 196 "✗ ERROR: Database directory not found"
        fi
    else
        gum style --foreground 196 "Drop cancelled"
    fi
else
    rem_db_name=$(gum input --placeholder "Enter database name to drop")

    if [ -z "$rem_db_name" ]; then
        gum style --foreground 196 "Database name cannot be empty"
        . ./dbms.sh
        return 1
    fi

    if [ -d "$dbms_dir/$rem_db_name" ]; then
        if gum confirm "Drop '$rem_db_name'? This action cannot be undone."; then
            gum spin --spinner dot --title "Dropping database '$rem_db_name'..." -- rm -rf "$dbms_dir/$rem_db_name"
            gum style --foreground 82 "✓ Database '$rem_db_name' dropped successfully"
        else
            gum style --foreground 196 "Drop cancelled"
        fi
    else
        gum style --foreground 196 "✗ ERROR: Database '$rem_db_name' does not exist"
    fi
fi

sleep 1
. ./dbms.sh
