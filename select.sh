#!/bin/bash

# if [ "$is_connected" != "true" ]; then
#     echo "ERROR: no db connection"
#     exit
# fi

source ./helpers.sh

# read -rp "enter table name you wnat to select on: " cur_table;

# declare columns;
# declare table;
# declare where_clouse;
# declare where_col;
# declare where_op;
# declare where_val;
# declare where_idx;
# declare -a selected_cols;

# declare -a selected_col_indeces;

extract(){
    columns=$( echo $sql_query| sed -n "s/.*SELECT \(.*\) FROM.*/\1/pi");

    table=$( echo $sql_query| sed -n "s/.*FROM \([^ ]*\).*/\1/pi");
    cur_table=$table;
    where_clouse=$( echo $sql_query| sed -n "s/.*WHERE \(.*\)/\1/pi");

    where_clouse=$(echo $where_clouse | sed 's/[[:space:]]*;$//');
    echo "$columns + $table + $where_clouse"
}

# disable file expantion gloupaly
parse(){
    if [[ "$columns" == "*"  ]]; then
        selected_cols=("${col_arr[@]}");
    else
        IFS=',' read -ra selected_cols<<<"$columns";
    fi

    for i in "${!selected_cols[@]}"; do
        selected_cols[$i]=$(echo "${selected_cols[$i]}"|xargs);
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
        where_idx=("${col_index_dic[$where_col]}");
    fi

    #loop on row data
    header=$(
        IFS=','
        echo "${selected_cols[*]}"
    );
    final_res+=("$header");
    while read -r row; do
        IFS=',' read -ra row_vals <<<"$row";
        cur_row_val="${row_vals[$where_idx]}";
        filtered=();
        
        if [[ -n $where_col ]]; then
            
            if ! evaluate_where "$cur_row_val" "$where_op" "$where_val" "${col_datatype_dic[$where_col]}"; then
                continue;
            fi
        fi
        for idx in "${selected_col_indeces[@]}"; do
            filtered+=("${row_vals[$idx]}");
        done
        
        data=$(
            IFS=','
            echo "${filtered[*]}"
        );
        final_res+=("$data");
    done <"$data_file";
}
desplay(){
    if [ ${#final_res[@]} -eq 0 ]; then
        echo "Empty set";
        return;
    fi
    declare -a header_cols;
    
    IFS=',' read -ra header_cols<<<"${final_res[0]}";

    col_width=();
    for col in "${header_cols[@]}"; do
        col_width+=("${#col}");
    done

    for ((i=1; i<${#final_res[@]}; i++)){
        IFS=',' read -ra row_data<<<"${final_res[$i]}";

        for j in "${!row_data[@]}"; do
            val=${row_data[$j]};
            len=${#val};
            [[ $val == "null" ]] && val="NULL";

            ((len > col_width[j])) && col_width[$j]=$len;
        done
    }

    # add_padding
    for i in "${!col_width[@]}"; do
        ((col_width[i] = col_width[i] + 2));
    done
    print_separator(){
        echo -n "+"
        for w in "${col_width[@]}"; do 
            printf "%${w}s" ""| tr ' ' '-';
            echo -n "+";
        done
        echo ""
    }
    print_separator;

    #print header
    echo -n "|"
    for i in "${!header_cols[@]}"; do 
        printf " %-$((col_width[$i]-1))s" "${header_cols[$i]}";
        echo -n "|";
    done
    echo ""

    print_separator;

    #print values

    for ((i=1; i<${#final_res[@]}; i++)){
        IFS=',' read -ra row_data<<<"${final_res[$i]}";

        echo -n "|"
        for j in "${!row_data[@]}"; do
            val=${row_data[$j]};
            len=${#val};
            [[ $val == "null" ]] && val="NULL";
            printf " %-$((col_width[$j]-1))s" "$val";
            echo -n "|"
        done
        echo "";
    }
    print_separator;
    echo "$((${#final_res[@]} - 1)) rows in set"


}


main_select(){
    
    declare -a history_arr;
    clear;
    while true; do
        # local variables to reset every loop
        local columns=""
        local table=""
        local where_clouse=""
        local where_col=""
        local where_op=""
        local where_val=""
        local where_idx=""
        local -a selected_cols=()
        local -a selected_col_indeces=()
        local -a final_res=() 
        
        echo "Enter your sql select query :)"
        read -p "ourSql> " sql_query;

        case "${sql_query,,}" in 
            exit|q|quit|bye|\\q)
                echo "Bye 👋";
                break;
                ;;
            clear)
                clear;
                continue;
                ;;
        esac
        sql_query=$(echo "$sql_query"|tr -s ' ');
        sql_query=$(echo "$sql_query" | sed 's/[[:space:]]*;$//');
        history_arr+=("$sql_query");

        set -f;
        extract;
        meta_file="$dbms_dir/$cur_db/$cur_table.meta"
        data_file="$dbms_dir/$cur_db/$cur_table.txt"
        populate_table_metadata;
        parse;
        execute_query;
        desplay;

        set +f;
    
    done
}

main_select;
. ./after_connection.sh;