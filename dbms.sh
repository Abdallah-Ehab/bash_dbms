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

#function for creating database
select option in "create database" "connect to database" "list databases" "drop database"; do
    case "$REPLY" in
    1)
        . ./src/db/create_db.sh
        break
        ;;
    2)
        . ./src/db/connect_to_db.sh
        break
        ;;
    3)
        . ./src/db/list_dbs.sh
        break
        ;;
    4)
        . ./src/db/drop_db.sh
        break
        ;;
    *)
        echo "$REPLY is not a valid option"
        break
        ;;
    esac
done
