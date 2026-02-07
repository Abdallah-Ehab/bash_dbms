#!/bin/bash
# this file to handle operations after connection to db

select option in "Select from table" "Update a table" "Delete from table" "Insert into table" "Create table" "List tables" "Drop table"; do
    case "$REPLY" in
    1)
        . ./src/crud/select.sh
        break
        ;;
    2)
        . ./src/crud/update.sh
        break
        ;;
    3)
        . ./src/crud/delete.sh
        break
        ;;
    4)
        . ./src/crud/insert.sh
        break
        ;;
    5)
        . ./src/table/create_table.sh
        break
        ;;
    6)
        . ./src/table/list_tables.sh 1
        break
        ;;
    7)
        . ./src/table/create_col.sh
        break
        ;;
    8)
        . ./src/table/drop_table.sh
        break
        ;;
    *)
        echo "$REPLY is not a valid option"
        break
        ;;
    esac
done

. ./src/after_connection.sh
