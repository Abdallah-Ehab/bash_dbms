#!/bin/bash

## this file is for inserting into the database

source ./src/helpers.sh

# Get table name
if [[ -z "$cur_table" ]]; then
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

    cur_table=$(gum choose "${tables[@]}" --header "Select a table to insert into")

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

## populate shared metadata structures
populate_table_metadata

# Show available columns
gum style --border double --padding "0 1" "Available columns: ${col_arr[*]}"

## read target columns
declare -A target_cols_set
col_input=$(gum input --placeholder "Enter the column names separated by commas (e.g. id,name)")

if [ -z "$col_input" ]; then
    gum style --foreground 196 "No columns selected"
    . ./src/after_connection.sh
    return 1
fi

IFS=',' read -ra target_cols <<<"$col_input"

for col in "${target_cols[@]}"; do
    col=$(echo "$col" | xargs) # trim whitespace
    if [[ ! -v col_datatype_dic["$col"] ]]; then
        gum style --foreground 196 "Error: Column '$col' doesn't exist."
        sleep 1
        . ./src/after_connection.sh
        return 1
    fi
    target_cols_set["$col"]=1
done

## build row data in correct column order
declare -a row_data_arr=()
declare -a current_pk_vals=()

for col in "${col_arr[@]}"; do
    if [[ -v target_cols_set["$col"] ]]; then
        col_value=$(gum input --placeholder "Enter value for $col (${col_datatype_dic[$col]})")

        if [ -z "$col_value" ]; then
            gum style --foreground 196 "Column '$col' cannot be empty"
            . ./src/after_connection.sh
            return 1
        fi

        ## datatype validation
        validate_value_by_type "$col_value" "${col_datatype_dic[$col]}" || {
            gum style --foreground 196 "Validation failed for column '$col' (must be ${col_datatype_dic[$col]})"
            . ./src/after_connection.sh
            return 1
        }

        ## if column is part of PK, collect value
        if [[ -v primary_key_dic["$col"] ]]; then
            current_pk_vals+=("$col_value")
        fi

        row_data_arr+=("$col_value")
    else
        row_data_arr+=("null")
    fi
done

## build primary key string
new_pk_str=$(
    IFS=','
    echo "${current_pk_vals[*]}"
)

## enforce primary key uniqueness
if [[ -v pk_value_set["$new_pk_str"] ]]; then
    gum style --foreground 196 "✗ Error: Primary Key violation! Value ($new_pk_str) already exists."
    sleep 1
    . ./src/after_connection.sh
    return 1
fi

## insert row
(
    IFS=','
    echo "${row_data_arr[*]}"
) >>"$data_file"

gum style --foreground 82 "✓ Record inserted successfully into table '$cur_table'"
sleep 1
. ./src/after_connection.sh
