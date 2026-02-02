#!/bin/bash
# this file to handle operations after connection to db

select option in "create table" "list tables" "insert into table" "drop table" "select from table" "disconnect from db" "add column to table"; do
    case "$REPLY" in
    1)
        . ./create_table.sh
        break
        ;;
    2)
        . ./list_tables.sh
        break
        ;;
    3)
        . ./insert.sh
        break
        ;;
    4)
        . ./drop_table.sh
        break
        ;;
    5)
        echo "Select functionality is not yet implemented"
        break
        ;;
    6)
        . ./helpers.sh 1
        break
        ;;
    7)
        . ./create_col.sh
        break
        ;;
    *)
        echo "$REPLY is not a valid option"
        break
        ;;
    esac
done

. ./after_connection.sh
