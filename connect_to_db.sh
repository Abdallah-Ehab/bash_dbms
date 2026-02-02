#!/bin/bash


## id db exists connect if not ask the user if he wants to create and connect at the same time
## connecting is simple you basically cd to the db directory

connect_to_db(){
    local db_name="";
    [ $# -eq 1 ] && db_name="$1" || read -p "enter the name of the db to connect to : " db_name;
    if [ -d "$dbms_dir/$db_name" ]; then
        echo
        echo -n "Connecting"

        # just a cute loading animation connecting...
        for i in {1..3}; do
            echo -n "."
            sleep 0.5  # 1 second is a bit slow for users, 0.5 feels snappier!
        done

        echo  "DB connected successfully"
        
        # cd "$dbms_dir/$cur_db";
        cur_db="$db_name"
        is_connected="true";
        . ./after_connection.sh
    else 
        echo "there is no database with this name"
        . ./main.sh
        # connect_automatically "$db_name"
    fi
}


connect_automatically(){
    local db_name="$1"
    select option in "yes" "No"; do
    case $REPLY in
    1)
       . ./create_db.sh "$1"
       connect_to_db "$1"
       break;
       ;;
    2|*)
        echo "failed to connect to db";
        exit;
        ;;
    esac
    done
}

connect_to_db "$@";