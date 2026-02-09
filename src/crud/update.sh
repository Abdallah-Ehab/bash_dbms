#!/bin/bash

## this file is for updating

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

    cur_table=$(gum choose "${tables[@]}" --header "Select a table to update")

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

gum style --border double --padding "0 1" "Available columns: ${col_arr[*]}"
user_input=$(gum input --placeholder "Enter column names to UPDATE separated by commas (e.g. name,salary)")

if [ -z "$user_input" ]; then
    gum style --foreground 196 "No columns selected"
    . ./src/after_connection.sh
    return 1
fi

condition=$(gum input --placeholder "Enter condition to filter rows (e.g. id=1, or leave empty to update all)")

# Parse target columns and trim whitespace
IFS=',' read -ra target_cols_raw <<<"$user_input"
target_cols=()
for col in "${target_cols_raw[@]}"; do
    col=$(echo "$col" | xargs) # Trim whitespace

    if [[ ! -v col_datatype_dic["$col"] ]]; then
        gum style --foreground 196 "Error: Column '$col' doesn't exist."
        . ./src/after_connection.sh
        return 1
    fi

    target_cols+=("$col")
done

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

# Ask for new values ONCE before the loop
declare -A new_values_dic
gum style --border double --border-foreground 212 --padding "1 1" "Enter the new values for columns to update:"
for col in "${target_cols[@]}"; do
    new_val=$(gum input --placeholder "Enter new value for '$col' (${col_datatype_dic[$col]})")
    new_val=$(echo "$new_val" | xargs)

    ## datatype validation
    validate_value_by_type "$new_val" "${col_datatype_dic[$col]}" || {
        gum style --foreground 196 "Datatype validation failed for '$col'"
        . ./src/after_connection.sh
        return 1
    }

    new_values_dic["$col"]="$new_val"
done

gum style --foreground 82 "✓ Values confirmed. Processing rows..."
sleep 1

tmp_file=$(mktemp)
updated_count=0

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
        old_pk_parts=()
        new_pk_parts=()

        ## build old pk
        for pk_col in "${primary_key_order_arr[@]}"; do
            idx="${primary_key_dic[$pk_col]}"
            old_pk_parts+=("${row_values[$idx]}")
        done
        old_pk=$(
            IFS=','
            echo "${old_pk_parts[*]}"
        )

        ## Apply the new values to this row
        for col in "${target_cols[@]}"; do
            idx="${col_index_dic[$col]}"
            row_values[$idx]="${new_values_dic[$col]}"
        done

        ## build new pk
        for pk_col in "${primary_key_order_arr[@]}"; do
            idx="${primary_key_dic[$pk_col]}"
            new_pk_parts+=("${row_values[$idx]}")
        done
        new_pk=$(
            IFS=','
            echo "${new_pk_parts[*]}"
        )

        ## enforce pk uniqueness (allow same row)
        if [[ "$new_pk" != "$old_pk" && -v pk_value_set["$new_pk"] ]]; then
            gum style --foreground 196 "✗ Error: Primary key constraint violation ($new_pk) already exists"
            rm -f "$tmp_file"
            . ./src/after_connection.sh
            return 1
        fi

        unset pk_value_set["$old_pk"]
        pk_value_set["$new_pk"]=1

        ((updated_count++))
    fi

    (
        IFS=','
        echo "${row_values[*]}"
    ) >>"$tmp_file"
done 3<"$data_file"

mv "$tmp_file" "$data_file"

if [[ $updated_count -eq 0 ]]; then
    gum style --foreground 82 "No rows matched the condition. No updates performed."
else
    gum style --foreground 82 "✓ Successfully updated $updated_count row(s)."
fi

sleep 1
. ./src/after_connection.sh
