#!/bin/bash

## this script is for creating db

create_db() {
    if [ $# -eq 1 ]; then
        cur_db="$1"
    else
        cur_db=$(gum input --placeholder "Enter the name of the database")
        if [ -z "$cur_db" ]; then
            gum style --foreground 196 "Database name cannot be empty"
            . ./dbms.sh
            return 1
        fi
    fi

    if [ -d "$dbms_dir/$cur_db" ]; then
        gum confirm "Database '$cur_db' already exists. Do you want to override?" && {
            gum spin --spinner dot --title "Recreating database..." -- rm -rf "$dbms_dir/$cur_db" &&
                mkdir -p "$dbms_dir/$cur_db" &&
                gum style --foreground 82 "✓ Database '$cur_db' recreated successfully"
        } || {
            gum style --foreground 196 "Operation cancelled"
        }
    else
        gum spin --spinner dot --title "Creating database..." -- mkdir -p "$dbms_dir/$cur_db"
        gum style --foreground 82 "✓ Database '$cur_db' created successfully"
    fi

    sleep 1
    . ./src/after_connection.sh
}

create_db "$@"
