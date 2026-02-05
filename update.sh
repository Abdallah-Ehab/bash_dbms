#!/bin/bash

## this file is for updating
## the user should enter the col_names to update separated by a comma example
## id,name,salary
## then the user will be asked for the values of the update prompting user according to the number of updates
## the code should check for hte data types of the cols and for the primary key constraint
## so this code is very similar to the insert code

source ./helpers.sh

read -rp "enter table name you eant to update: " cur_table;
meta_file="$dbms_dir/$cur_db/$cur_table.meta"
data_file="$dbms_dir/$cur_db/$cur_table.txt"

populate_table_metadata

read -rp "enter the names of the columns needed separated by [,] " user_input
read -rp "enter the condition eg: col_name [=<>|!=] value (or empty) " condition

IFS=',' read -ra target_cols <<<"$user_input"

## parse condition
if [[ -n "$condition" ]]; then
    if [[ $condition =~ ^([^=!<>[:space:]]+)[[:space:]]*(<>|!=|=|>|<)[[:space:]]*(.*)$ ]]; then
        con_col_name="${BASH_REMATCH[1]}"
        op="${BASH_REMATCH[2]}"
        con_val="${BASH_REMATCH[3]}"
        cond_col_index="${col_index_dic[$con_col_name]}"
        [[ "$op" == "<>" ]] && op="!="
    else
        echo "Invalid condition"
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

while read -r row; do
    IFS=',' read -ra row_values <<<"$row"

    match=true
    if [[ -n "$condition" ]]; then
        match=false
        case "$op" in
        "=") [[ "${row_values[$cond_col_index]}" == "$con_val" ]] && match=true ;;
        "!=") [[ "${row_values[$cond_col_index]}" != "$con_val" ]] && match=true ;;
        ">") [[ "${row_values[$cond_col_index]}" -gt "$con_val" ]] && match=true ;;
        "<") [[ "${row_values[$cond_col_index]}" -lt "$con_val" ]] && match=true ;;
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

        for col in "${target_cols[@]}"; do
            idx="${col_index_dic[$col]}"
            read -rp "enter the value for col [$col] " new_val

            ## datatype validation
            validate_value_by_type "$new_val" "${col_datatype_dic[$col]}" || {
                echo "Datatype validation failed for $col"
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
            echo "Error: primary key constraint violation ($new_pk)"
            exit 1
        fi

        unset pk_value_set["$old_pk"]
        pk_value_set["$new_pk"]=1
    fi

    (
        IFS=','
        echo "${row_values[*]}"
    ) >>"$tmp_file"
done <"$data_file"

mv "$tmp_file" "$data_file"
