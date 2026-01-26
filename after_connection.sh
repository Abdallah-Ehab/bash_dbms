#!/bin/bash
# this file to handle operations after connection to db

select option in "create table" "insert into table" "list tables" "drop table" "select from table" "disconnect from db";
    do
        case "$REPLY" in
        1)
            . ./create_table.sh
            break;
            ;;
        *)
           echo "$REPLY is not a valid option"
            break;
            ;;
        esac
    done

. ./after_connection.sh