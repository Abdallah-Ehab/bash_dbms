#!/bin/bash

#check if we are connected

# Collect table names for selection
declare -a tables=()
for file in "$dbms_dir/$cur_db"/*.txt; do
    if [ -f "$file" ]; then
        table_name=$(basename "$file" .txt)
        tables+=("$table_name")
    fi
done

if [ ${#tables[@]} -eq 0 ]; then
    gum style --foreground 196 "No tables found in database '$cur_db'"
    sleep 1
    . ./src/after_connection.sh
    return 1
fi

table=$(gum choose "${tables[@]}" --header "Select a table to drop")

if [ -z "$table" ]; then
    gum style --foreground 196 "No table selected"
    . ./src/after_connection.sh
    return 1
fi

if [ -f "$dbms_dir/$cur_db/$table.txt" ]; then
    if gum confirm "Are you sure you want to drop table '$table'? This action cannot be undone."; then
        gum spin --spinner dot --title "Dropping table '$table'..." -- rm -f "$dbms_dir/$cur_db/$table.txt" "$dbms_dir/$cur_db/$table.meta"
        gum style --foreground 82 "✓ Table '$table' dropped successfully"
    else
        gum style --foreground 196 "Drop cancelled"
    fi
else
    gum style --foreground 196 "✗ ERROR: table '$table' does not exist"
fi

sleep 1
. ./src/after_connection.sh
