#!/bin/bash

#this script will be the main dbms script
#I don't know what it handles yet but of course it handles something xD

#some shared variables among all files
dbms_dir="$HOME"/dbms_dir;


make_dbms_dir(){
    [ -d $dbms_dir ] || mkdir -p $dbms_dir;
}

#function for creating database
select option in "create database" "connect to database" "list databases" "drop database";
    do
        case "$REPLY" in
        1)
            create_db
            ;;
        2)
            connect_to_db
            ;;
        3)
            list_dbs
            ;;
        4)
            drop_db
            ;;
        *)
            "$REPLY is not a valid option"
            ;;
        esac
    done