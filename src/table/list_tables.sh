#!/bin/bash

if [ -d "$dbms_dir/$cur_db" ] && [ "$(ls -A "$dbms_dir/$cur_db" 2>/dev/null)" ]; then
    # Collect table names
    declare -a tables=()
    for file in "$dbms_dir/$cur_db"/*.txt; do
        if [ -f "$file" ]; then
            table_name=$(basename "$file" .txt)
            tables+=("$table_name")
        fi
    done

    if [ ${#tables[@]} -gt 0 ]; then
        # Create table list for display
        table_list=$(printf '%s\n' "${tables[@]}")
        gum style --border double --border-foreground 212 --padding "1 2" --align center "$(printf "Tables in $cur_db:\n%s" "$table_list")"
    else
        gum style --foreground 196 "No tables found"
    fi
else
    gum style --foreground 196 "No tables found"
fi

sleep 2
. ./src/after_connection.sh
