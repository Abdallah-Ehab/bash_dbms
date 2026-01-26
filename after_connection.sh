#!/bin/bash
# this file to handle operations after connection to db

select option in "create table"  "list tables" "insert into table"  "drop table" "select from table" "disconnect from db";
    do
        case "$REPLY" in
        1)
            . ./create_table.sh
            break;
            ;;
        2)
            . ./list_tables.sh;
            break;;

        4)
            . ./drop_table.sh;
            break;;
        6)
            . ./helpers.sh 1;
            break;;
        *)
           echo "$REPLY is not a valid option"
            break;
            ;;
        esac
    done

. ./after_connection.sh