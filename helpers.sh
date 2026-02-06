#!/bin/bash

# this is for some helper functions where the functionality I noticed were repetitive

disconnect_and_rm_curdb() {
    cur_db=""
    is_connected=false
}

## populate_table_metadata
## this function populates all shared metadata structures
## required globals before calling:
##   meta_file
##   data_file
##
## populated data structures:
## 1- col_datatype_dic        col -> datatype
## 2- col_arr                ordered columns
## 3- col_index_dic          col -> index
## 4- primary_key_order_arr  ordered pk columns
## 5- primary_key_dic        pk_col -> index
## 6- pk_value_set           set of existing pk strings

populate_table_metadata() {

    declare -gA col_datatype_dic
    declare -ga col_arr
    declare -gA col_index_dic
    declare -ga primary_key_order_arr
    declare -gA primary_key_dic
    declare -gA pk_value_set

    col_arr=()
    primary_key_order_arr=()
    pk_value_set=()
    all_tables=();

    ## 0- get all tables


    if [ -d "$dbms_dir/$cur_db" ] && [ "$(ls -A "$dbms_dir/$cur_db" 2>/dev/null)" ]; then
        echo "Tables in $cur_db:"
        
        #print tables without .meta, .txt
        for file in "$dbms_dir/$cur_db"/*.txt; do
            if [ -f "$file" ]; then
                table_name=$(basename "$file" .txt) # basename ==> get file name only
                all_tables+=("$table_name");
            fi
        done

    else
        echo "No tables found"
    fi
    ## 1- parse meta file
    while IFS=':' read -r key value; do
        if [[ "$key" == "primary_key" ]]; then
            IFS=',' read -ra primary_key_order_arr <<<"$value"
        else
            col_datatype_dic["$key"]="$value"
            col_arr+=("$key")
        fi
    done <"$meta_file"

    ## 2- build column index map
    for i in "${!col_arr[@]}"; do
        col_index_dic["${col_arr[$i]}"]=$i
    done

    ## 3- build primary_key_dic (pk_col -> column index)
    for pk_col in "${primary_key_order_arr[@]}"; do
        primary_key_dic["$pk_col"]="${col_index_dic[$pk_col]}"
    done

    ## 4- build pk_value_set from data file
    [[ ! -f "$data_file" ]] && return

    while read -r row; do
        IFS=',' read -ra row_vals <<<"$row"
        pk_parts=()
        for pk_col in "${primary_key_order_arr[@]}"; do
            idx="${primary_key_dic[$pk_col]}"
            pk_parts+=("${row_vals[$idx]}")
        done
        pk_key=$(
            IFS=','
            echo "${pk_parts[*]}"
        )
        pk_value_set["$pk_key"]=1
    done <"$data_file"
}

validate_value_by_type() {
    local val="$1"
    local type="$2"

    case "$type" in
    int) [[ "$val" =~ ^[0-9]+$ ]] ;;
    varchar*) [[ "$val" =~ ^[a-zA-Z0-9[:space:]]*$ ]] ;;
    *) return 0 ;;
    esac
}
