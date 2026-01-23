#!/bin/bash


## id db exists connect if not ask the user if he wants to create and connect at the same time
## connecting is simple you basically cd to the db directory
db_name;
is_connected=false;
connect_to_db(){
    [ $# -eq 1 ] || read -p "enter the name of the db to connect to : " db_name;
    if [ -d "$dbms_dir/$db_name" ]; then
    echo
    echo -n connecting
    while "1..3"; do
    echo -n .;
    sleep 1;
    done
    echo "db connected successfully";
    cd "$dbms_dir/$db_name";
    is_connected=true;
    else 
        echo "there is no database with this name"
        connect_automatically
    fi
}


connect_automatically(){
    select option in "yes" "No"; do
    case $REPLY in
    1)
       . ./create_db $db_name
       connect_to_db $db_name
       ;;
    2)
        echo "failed to connect to db";
        exit;
        ;;
    *)
        echo "failed to connect to db";
        exit;
        ;;
    esac
    done
}

[ $# -eq 1 ] && connect_to_db $1 || connect_to_db