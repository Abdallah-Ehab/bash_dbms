#!/bin/bash

## this file is for deleting rows from a table
## the user will enter a condition to filter which rows to delete
## example: id=1 or name=john or salary>5000
## if no condition is entered, all rows will be deleted (scary but useful)
## we need to:
## 1- parse the condition (same as update script)
## 2- loop through rows and check which ones match the condition
## 3- only write non-matching rows to the temp file
## 4- replace the original file with the temp file
## we also need to update the pk_value_set to remove deleted primary keys
## this is simpler than update since we don't need to ask for new values
## just check condition and skip writing the row if it matches

source ./src/helpers.sh

read -rp "enter table name you want to delete from: " cur_table
meta_file="$dbms_dir/$cur_db/$cur_table.meta"
data_file="$dbms_dir/$cur_db/$cur_table.txt"

# Check if table exists
if [[ ! -f "$meta_file" || ! -f "$data_file" ]]; then
    echo "ERROR: Table '$cur_table' not found"
    exit 1
fi

populate_table_metadata

read -rp "enter the condition to filter rows for deletion (e.g. id=1 or empty to delete all): " condition

## show warning if deleting all rows
if [[ -z "$condition" ]]; then
    read -rp "WARNING: You're about to delete ALL rows from '$cur_table'. Continue? (yes/no): " confirm </dev/tty
    if [[ "$confirm" != "yes" ]]; then
        echo "Deletion cancelled."
        exit 0
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
        # Trim whitespace from condition value
        con_val=$(echo "$con_val" | xargs)

        # Validate that the condition column exists
        if [[ ! -v col_index_dic["$con_col_name"] ]]; then
            echo "Error: Column ($con_col_name) doesn't exist."
            exit 1
        fi
        cond_col_index="${col_index_dic[$con_col_name]}"
        [[ "$op" == "<>" ]] && op="!="
    else
        echo "Invalid condition format. Use: column_name [=|!=|<|>|<>] value"
        exit 1
    fi
fi

## the deletion loop
## we loop through all rows
## if a row matches the condition, we DON'T write it to the temp file (effectively deleting it)
## if a row doesn't match, we write it to the temp file (keeping it)
## at the end we replace the original file with the temp file
## we also need to rebuild the pk_value_set since we're deleting rows

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
        ## row matches condition - DELETE it (don't write to temp file)
        echo "Deleting row: ${row_values[*]}"

        ((deleted_count++))
    else
        ## row doesn't match - KEEP it (write to temp file)
        (
            IFS=','
            echo "${row_values[*]}"
        ) >>"$tmp_file"
    fi
done 3<"$data_file"

mv "$tmp_file" "$data_file"

if [[ $deleted_count -eq 0 ]]; then
    echo "No rows matched the condition. No deletions performed."
else
    echo "Successfully deleted $deleted_count row(s)."
fi
