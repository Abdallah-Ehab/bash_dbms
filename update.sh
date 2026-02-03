#!/bin/bash

## this file is for updating
## the user should enter the col_names to update separated by a comma example
## id,name,salary
## then the user will be asked for the values of the update prompting user according to the number of updates
## the code should check for hte data types of the cols and for the primary key constraint
## so this code is very similar to the insert code

meta_file="$dbms_dir/$cur_db/$cur_table.meta"
data_file="$dbms_dir/$cur_db/$cur_table.txt"

declare -A col_datatype_dic # the
declare -A primary_key_dic
declare -a primary_key_order_arr
declare -A pk_value_set
declare -A col_index_dic

##1- parse col_name : datatype from meta data
while IFS=':' read -r key value; do
    if [[ "$key" = "primary_key" ]]; then
        IFS=',' read -ra primary_key_order_arr <<<"$value"
    else
        col_datatype_dic["$key"]="$value"
    fi
done <"$meta_file"

##2- this code is for building column_index_dic key=col_name value=index
index=0
while IFS=':' read -r key value; do
    col_index_dic[$key]=$index
    ((index++))
done <"$meta_file"

##3- making the primary_key_col_order which get the order of the primary_cols right
for pk_col in "${primary_key_order_arr[@]}"; do
    primary_key_dic["$pk_col"]="${col_index_dic[$pk_col]}"
done

##4- read the data file to make the pk_value_set
while read -r row; do
    IFS=',' read -ra row_values <<<"$row"
    pk_parts=()
    for pk_col in "${primary_key_order_arr[@]}"; do
        idx="${primary_key_dic[$pk_col]}"
        pk_parts+=("${row_values[$idx]}")
    done
    pk_key=$(
        IFS=','
        echo "${pk_parts[*]}"
    )
    pk_value_set["$pk_key"]=1
done <"$data_file"

##4- read the prompt from the user

read -rp "enter the names of the columns needed separated by [,]" user_input

read -rp "enter the condition eg: where col_name [=<>] value" condition

IFS=',' read -ra target_cols <<<"$user_input"

## we need to match this string where (*) ([=<>]) (*) group $1 is the col_name group $2 is the value
if [[ $condition =~ ^([^=!<>]+)(<>|!=|=|>|<)(.*)$ ]]; then
    con_col_name="${BASH_REMATCH[1]}"
    op="${BASH_REMATCH[2]}"
    con_val="${BASH_REMATCH[3]}"
fi

## we need to get the target col index in the condition:
cond_col_index="${col_index_dic["$con_col_name"]}"

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

    ## update row if matched
    if $match; then
        for col in "${target_cols[@]}"; do
            idx="${col_index_dic[$col]}"
            read -rp "enter the value for col [$col] " new_val
            row_values[$idx]="$new_val"
        done
    fi

    (
        IFS=','
        echo "${row_values[*]}"
    ) >>"$tmp_file"
done <"$data_file"

mv "$tmp_file" "$data_file"

##data structures we have :
# 1- primary_key_column_order type=arr      [pk_col1,pk_col2,et...] ordered
# 2- col_index_dic type dic                 col_index_dic[col1] = order
# 3- primary_key_value_set   type = set
