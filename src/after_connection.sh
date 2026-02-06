#!/bin/bash
# this file to handle operations after connection to db

select option in "create table" "list tables" "insert into table" "drop table" "select from table" "disconnect from db" "add column to table" "update on table"; do
    case "$REPLY" in
    1)
        . ./src/table/create_table.sh
        break
        ;;
    2)
        . ./src/table/list_tables.sh
        break
        ;;
    3)
        . ./src/crud/insert.sh
        break
        ;;
    4)
        . ./src/table/drop_table.sh
        break
        ;;
    5)
        . ./src/crud/select.sh
        break
        ;;
    6)
        . ./src/helpers.sh 1
        break
        ;;
    7)
        . ./src/table/create_col.sh
        break
        ;;
    8)
        . ./src/crud/update.sh
        break
        ;;
    *)
        echo "$REPLY is not a valid option"
        break
        ;;
    esac
done

. ./src/after_connection.sh
