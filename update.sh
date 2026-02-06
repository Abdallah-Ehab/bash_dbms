#!/bin/bash

## this file is for updating
## the user should enter the col_names to update separated by a comma example
## id,name,salary
## then the user will be asked for the values of the update prompting user according to the number of updates
## the code should check for the data types of the cols and for the primary key constraint
## so this code is very similar to the insert code

source ./helpers.sh

read -rp "enter table name you want to update: " cur_table
meta_file="$dbms_dir/$cur_db/$cur_table.meta"
data_file="$dbms_dir/$cur_db/$cur_table.txt"

# Check if table exists
if [[ ! -f "$meta_file" || ! -f "$data_file" ]]; then
    echo "ERROR: Table '$cur_table' not found"
    exit 1
fi

populate_table_metadata

read -rp "enter the names of the columns you want to UPDATE separated by [,] (e.g. name,salary): " user_input
read -rp "enter the condition to filter rows (e.g. id=1 or empty to update all): " condition

# Parse target columns and trim whitespace
IFS=',' read -ra target_cols_raw <<<"$user_input"
target_cols=()
for col in "${target_cols_raw[@]}"; do
    col=$(echo "$col" | xargs) # Trim whitespace

    # Validate column exists
    if [[ ! -v col_datatype_dic["$col"] ]]; then
        echo "Error: Column ($col) doesn't exist."
        exit 1
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

# the loop where actually updating data will happen
## how update will happen
##1- we will loop over the rows of the data file
##2- if we found the correct col using the indices processed already and if the row has the condition
##3- we ask the user for the value
##4- we will make a new array called new_row_values to append to new values
##then we will override the whole file when the user updates optimal ??! I don't know
## but if not optimal how to replace the row itself in a file
## I can't use awk since I need a lot of variables and data structures I already made which in awk is a headache
##note we can process the row indices that has the condition == true at first before the update loop

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

        echo "Updating row with current values: ${row_values[*]}"

        for col in "${target_cols[@]}"; do
            idx="${col_index_dic[$col]}"
            read -rp "enter the value for col [$col]: " new_val </dev/tty
            # Trim whitespace from input
            new_val=$(echo "$new_val" | xargs)

            ## datatype validation
            validate_value_by_type "$new_val" "${col_datatype_dic[$col]}" || {
                echo "Datatype validation failed for $col"
                rm -f "$tmp_file"
                exit 1
            }

            row_values[$idx]="$new_val"
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
            echo "Error: primary key constraint violation ($new_pk) already exists"
            rm -f "$tmp_file"
            exit 1
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
    echo "No rows matched the condition. No updates performed."
else
    echo "Successfully updated $updated_count row(s)."
fi
