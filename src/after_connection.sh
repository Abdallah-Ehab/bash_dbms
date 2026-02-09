#!/bin/bash
# this file to handle operations after connection to db

while true; do
    option=$(gum choose \
        "Select from table" \
        "Update a table" \
        "Delete from table" \
        "Insert into table" \
        "Create table" \
        "List tables" \
        "Drop table" \
        "Disconnect" \
        --header "Database: $cur_db")

    case "$option" in
    "Select from table")
        . ./src/crud/select.sh
        ;;
    "Update a table")
        . ./src/crud/update.sh
        ;;
    "Delete from table")
        . ./src/crud/delete.sh
        ;;
    "Insert into table")
        . ./src/crud/insert.sh
        ;;
    "Create table")
        . ./src/table/create_table.sh
        ;;
    "List tables")
        . ./src/table/list_tables.sh 1
        ;;
    "Drop table")
        . ./src/table/drop_table.sh
        ;;
    "Disconnect")
        gum style --foreground 82 "✓ Disconnected from database '$cur_db'"
        cur_db=""
        is_connected="false"
        sleep 1
        . ./dbms.sh
        ;;
    *)
            gum style --foreground 196 "Invalid option"
        ;;
    esac
done
