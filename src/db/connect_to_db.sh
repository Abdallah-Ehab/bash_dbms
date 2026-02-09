#!/bin/bash

## id db exists connect if not ask the user if he wants to create and connect at the same time
## connecting is simple you basically cd to the db directory

connect_to_db() {
    local db_name=""
    if [ $# -eq 1 ]; then
        db_name="$1"
    else
        # Get list of databases and use gum filter
        local db_list=$(ls -1 "$dbms_dir" 2>/dev/null)
        if [ -z "$db_list" ]; then
            gum style --foreground 196 "No databases found"
            sleep 1
            . ./dbms.sh
            return 1
        fi
        db_name=$(echo "$db_list" | gum filter --placeholder "Select a database to connect to...")
        if [ -z "$db_name" ]; then
            gum style --foreground 196 "No database selected"
            . ./dbms.sh
            return 1
        fi
    fi

    if [ -d "$dbms_dir/$db_name" ]; then
        gum spin --spinner dot --title "Connecting to database '$db_name'..." -- sleep 1

        cur_db="$db_name"
        is_connected="true"
        gum style --foreground 82 "✓ Connected to database '$db_name' successfully"
        sleep 1
        . ./src/after_connection.sh
    else
        gum style --foreground 196 "✗ Database '$db_name' does not exist"
        sleep 1

        if gum confirm "Would you like to create this database?"; then
            . ./src/db/create_db.sh "$db_name"
            connect_to_db "$db_name"
        else
            . ./dbms.sh
        fi
    fi
}

connect_to_db "$@"
