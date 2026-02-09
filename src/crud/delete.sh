#!/bin/bash

## this file is for deleting rows from a table

source ./src/helpers.sh

# Get table name
if [[ -z "$cur_table" ]]; then
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

    cur_table=$(gum choose "${tables[@]}" --header "Select a table to delete from")

    if [ -z "$cur_table" ]; then
        gum style --foreground 196 "No table selected"
        . ./src/after_connection.sh
        return 1
    fi
fi

meta_file="$dbms_dir/$cur_db/$cur_table.meta"
data_file="$dbms_dir/$cur_db/$cur_table.txt"

# Check if table exists
if [[ ! -f "$meta_file" || ! -f "$data_file" ]]; then
    gum style --foreground 196 "✗ ERROR: Table '$cur_table' not found"
    sleep 1
    . ./src/after_connection.sh
    return 1
fi

populate_table_metadata

condition=$(gum input --placeholder "Enter condition to filter rows for deletion (e.g. id=1, or leave empty to delete all)")

## show warning if deleting all rows
if [[ -z "$condition" ]]; then
    if ! gum confirm "⚠️  WARNING: You're about to delete ALL rows from '$cur_table'. Continue?"; then
        gum style --foreground 196 "Deletion cancelled."
        sleep 1
        . ./src/after_connection.sh
        return 0
    fi
fi

## parse condition
cond_col_index=""
con_col_name=""
op=""
con_val=""

if [[ -n "$condition" ]]; then
    if [[ $condition =~ ^([^=!<>[:space:]]+)[[:space:]]*(<>|!=|=|>|<)[[:space:]]*(.*)$ ]]; then
        con_col_name="${BASH_REMATCH[1]}"
        op="${BASH_REMATCH[2]}"
        con_val="${BASH_REMATCH[3]}"
        con_val=$(echo "$con_val" | xargs)

        if [[ ! -v col_index_dic["$con_col_name"] ]]; then
            gum style --foreground 196 "Error: Column '$con_col_name' doesn't exist."
            . ./src/after_connection.sh
            return 1
        fi
        cond_col_index="${col_index_dic[$con_col_name]}"
        [[ "$op" == "<>" ]] && op="!="
    else
        gum style --foreground 196 "Invalid condition format. Use: column_name [=|!=|<|>|<>] value"
        . ./src/after_connection.sh
        return 1
    fi
fi

tmp_file=$(mktemp)
deleted_count=0

while read -r row <&3; do
    IFS=',' read -ra row_values <<<"$row"

    match=true
    if [[ -n "$condition" ]]; then
        match=false
        row_val="${row_values[$cond_col_index]}"
        case "$op" in
        "=") [[ "$row_val" == "$con_val" ]] && match=true ;;
        "!=") [[ "$row_val" != "$con_val" ]] && match=true ;;
        ">")
            if [[ "$row_val" =~ ^[0-9]+$ && "$con_val" =~ ^[0-9]+$ ]]; then
                [[ "$row_val" -gt "$con_val" ]] && match=true
            fi
            ;;
        "<")
            if [[ "$row_val" =~ ^[0-9]+$ && "$con_val" =~ ^[0-9]+$ ]]; then
                [[ "$row_val" -lt "$con_val" ]] && match=true
            fi
            ;;
        esac
    fi

    if $match; then
        ## row matches condition - DELETE it
        gum style --padding "0 1" --foreground 196 "Deleting row: ${row_values[*]}"
        ((deleted_count++))
    else
        ## row doesn't match - KEEP it
        (
            IFS=','
            echo "${row_values[*]}"
        ) >>"$tmp_file"
    fi
done 3<"$data_file"

mv "$tmp_file" "$data_file"

if [[ $deleted_count -eq 0 ]]; then
    gum style --foreground 82 "No rows matched the condition. No deletions performed."
else
    gum style --foreground 82 "✓ Successfully deleted $deleted_count row(s)."
fi

sleep 1
. ./src/after_connection.sh
