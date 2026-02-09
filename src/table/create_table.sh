#!/bin/bash

## this is the file for creating a table
## edgecases to handle :
# 1- what if a table with the same name exists

## how table is created :
# 1- a text file with the name the user provided is created
# 2- the user is asked to add a column
# 3- the user is asked about the data type of the column

cur_table=$(gum input --placeholder "Enter the name of the table")

if [ -z "$cur_table" ]; then
    gum style --foreground 196 "Table name cannot be empty"
    . ./src/after_connection.sh
    return 1
fi

create_table() {
    touch "$dbms_dir"/"$cur_db"/"$cur_table.meta"
    touch "$dbms_dir"/"$cur_db"/"$cur_table.txt"

    declare -a col_names_arr=()

    while true; do
        col_name=$(gum input --placeholder "Enter column name (or type 'done' to finish)")

        if [ "$col_name" == "done" ] || [ -z "$col_name" ]; then
            if [ ${#col_names_arr[@]} -eq 0 ]; then
                gum style --foreground 196 "At least one column is required"
                continue
            fi
            break
        fi

        col_type=$(gum choose "int" "string" --header "Select data type for column: $col_name")

        if [ -z "$col_type" ]; then
            gum style --foreground 196 "Please select a valid data type"
            continue
        fi

        echo "$col_name:$col_type" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
        col_names_arr+=("$col_name")
        gum style --foreground 82 "✓ Column '$col_name' added as $col_type"
    done

    # Ask for primary key columns
    echo ""
    gum style --border double --padding "0 1" "Available columns: ${col_names_arr[*]}"
    pk_input=$(gum input --placeholder "Enter primary key column names separated by commas (e.g. id or id,name)")

    if [ -n "$pk_input" ]; then
        echo "primary_key:$pk_input" >>"$dbms_dir"/"$cur_db"/"$cur_table.meta"
        gum style --foreground 82 "✓ Primary key set to: $pk_input"
    fi

    gum style --foreground 82 "✓ Table structure for '$cur_table' created successfully"
}

if [[ -f "$dbms_dir/$cur_db/$cur_table.txt" || -f "$dbms_dir/$cur_db/$cur_table.meta" ]]; then
    if gum confirm "Table '$cur_table' already exists. Do you want to overwrite it?"; then
        rm -f "$dbms_dir/$cur_db/$cur_table.txt" "$dbms_dir/$cur_db/$cur_table.meta"
        create_table
    else
        gum style --foreground 196 "Table create cancelled"
    fi
else
    create_table
fi

sleep 1
. ./src/after_connection.sh
