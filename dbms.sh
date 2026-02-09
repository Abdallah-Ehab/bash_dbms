#!/bin/bash

#this script will be the main dbms script
#I don't know what it handles yet but of course it handles something xD

#refactoring some variables to make them shared among different .sh files
## since I'm a dodo bird and I couldn't realise how variables are shared from the beginning

#some shared variables among all files
export dbms_dir="$HOME"/dbms_dir
export cur_db=""
export is_connected="false"

make_dbms_dir() {
    [ -d $dbms_dir ] || mkdir -p $dbms_dir
}

make_dbms_dir
. ./src/art.sh

# Main database menu using gum choose
while true; do
    option=$(gum choose "Create Database" "Connect to Database" "List Databases" "Drop Database" "Exit" --header "Database Operations")

    case "$option" in
    "Create Database")
        . ./src/db/create_db.sh
        ;;
    "Connect to Database")
        . ./src/db/connect_to_db.sh
        ;;
    "List Databases")
        . ./src/db/list_dbs.sh
        ;;
    "Drop Database")
        . ./src/db/drop_db.sh
        ;;
    "Exit")
        gum style --foreground 212 "Goodbye! 👋"
        exit 0
        ;;
    *)
        gum style --foreground 196 "Invalid option"
        ;;
    esac
done
