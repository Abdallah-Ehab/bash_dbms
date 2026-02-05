#!/bin/bash
# select from table functionality is not yet implemented


# if [ "$is_connected" != "true" ]; then
#     echo "ERROR: no db connection"
#     exit
# fi

source ./helpers.sh

read -rp "enter table name you wnat to select on: " cur_table;
# meta_file="$dbms_dir/$cur_db/$cur_table.meta"
# data_file="$dbms_dir/$cur_db/$cur_table.txt"


meta_file="/home/mahmoudnabil/dbms_dir/iti/$cur_table.meta"
data_file="/home/mahmoudnabil/dbms_dir/iti/$cur_table.txt"


populate_table_metadata

read -p "Enter your sql select query: " sql_query;


sql_query=$(echo "$sql_query"|tr -s ' ');
# sql_query=$(echo "$sql_query" | sed 's/[[:space:]]*;$//')
echo "$sql_query"

declare columns;
declare table;
declare where_clouse;
declare where_col;
declare where_op;
declare where_val;
declare where_idx;
declare -a selected_cols;

declare -a selected_col_indeces;

extract(){
    columns=$( echo $sql_query| sed -n "s/.*SELECT \(.*\) FROM.*/\1/pi");

    table=$( echo $sql_query| sed -n "s/.*FROM \([^ ]*\).*/\1/pi");

    where_clouse=$( echo $sql_query| sed -n "s/.*WHERE \(.*\)/\1/pi");

    where_clouse=$(echo $where_clouse | sed 's/[[:space:]]*;$//');
    echo "$columns + $table + $where_clouse"
}

parse(){
    if [[ $columns == *  ]]; then
        selected_cols=("${col_arr[@]}");
    else
        IFS=',' read -ra selected_cols<<<"$columns";
    fi
    for i in "${!selected_cols[@]}"; do
        selected_cols[$i]=$(echo "${selected_cols[$i]}"|xargs);
        # echo "${selected_cols[$i]}";
    done;

    for col in "${selected_cols[@]}"; do 
        if [[ ! -v col_index_dic[$col] ]]; then
            echo "Error col in query statment not exist"
            . ./after_connection
            # exit 1;
        fi
    done;

    if [[ $where_clouse =~  ([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*(=|!=|>|<|>=|<=)[[:space:]]*(.*) ]]; then
        where_col="${BASH_REMATCH[1]}";
        where_op="${BASH_REMATCH[2]}";
        where_val="${BASH_REMATCH[3]}";
    fi


    echo "$where_col:$where_op:$where_val";
}

evaluate_where(){
    local row_val=$1;
    local op=$2;
    local expected_val=$3;
    local data_type=$4;

    case $op in
    "=")
        [[ "$row_val" == "$expected_val" ]]
        ;;
    "!=")
        [[ "$row_val" != "$expected_val" ]]
        ;;
    ">")
        if [[ "$data_type" == "int" ]]; then
            (( row_val > $expected_val ))
        else 
            [[ "$row_val" > "$expected_val" ]]
        fi
        ;;

    "<")
        if [[ "$data_type" == "int" ]]; then
            (( row_val < $expected_val ))
        else 
            [[ "$row_val" < "$expected_val" ]]
        fi
        ;;

    ">=")
        if [[ "$data_type" == "int" ]]; then
            (( row_val >= $expected_val ))
        else 
            [[ "$row_val" > "$expected_val" ]] || [[ "$row_val" == "$expected_val" ]]
        fi
        ;;
    
    "<=")
        if [[ "$data_type" == "int" ]]; then
            (( row_val <= $expected_val ))
        else 
            [[ "$row_val" < "$expected_val" ]] || [[ "$row_val" == "$expected_val" ]]
        fi
        ;;
    
    
    esac
}

execute_query(){
    for col in "${selected_cols[@]}"; do 
        if [[ ! -v col_index_dic[$col] ]]; then
            echo "Error col in query statment not exist"
            exit 1;
        fi
    done;

    for col in "${selected_cols[@]}"; do
        selected_col_indeces+=("${col_index_dic[$col]}");
    done
    if [[ -n $where_col ]]; then
        echo "insideeeee"
        where_idx=("${col_index_dic[$where_col]}");
    fi

    echo "where_col" "$where_col" "where_idx" "$where_idx";
    #loop on row data
    final_res=();
    header=$(
        IFS=','
        echo "${selected_cols[*]}"
    );
    final_res+=("$header");
    while read -r row; do
        IFS=',' read -ra row_vals <<<"$row";
        cur_row_val="${row_vals[$where_idx]}";
        filtered=();
        if evaluate_where "$cur_row_val" "$where_op" "$where_val" "${col_datatype_dic[$where_col]}"; then
            echo "yesssssssssssssssssssssssssssss"
            for idx in "${selected_col_indeces[@]}"; do
                filtered+=("${row_vals[$idx]}");
            done
            
            data=$(
                IFS=','
                echo "${filtered[*]}"
            );
            final_res+=("$data");

        fi
    done <"$data_file";

    echo "${selected_col_indeces[@]}"
    echo "$data"




}
extract;
parse;
execute_query;
echo "${final_res[@]}";
# echo "${selected_cols[@]}";
# select we,   rre   from users