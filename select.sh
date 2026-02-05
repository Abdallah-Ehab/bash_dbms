#!/bin/bash
# select from table functionality is not yet implemented


# if [ "$is_connected" != "true" ]; then
#     echo "ERROR: no db connection"
#     exit
# fi

read -p "Enter your sql select query: " sql_query;
sql_query=$(echo "$sql_query"|tr -s ' ');
echo "$sql_query"

declare columns;
declare table;
declare where_clouse;

declare -a selected_cols;
declare -a selected_cols_idx;

extract(){
    columns=$( echo $sql_query| sed -n "s/.*SELECT \(.*\) FROM.*/\1/pi");

    table=$( echo $sql_query| sed -n "s/.*FROM \([^ ]*\).*/\1/pi");

    where_clouse=$( echo $sql_query| sed -n "s/.*WHERE \(.*\)/\1/pi");


    echo "$columns + $table + $where_clouse"
}

parse(){
    IFS=',' read -ra selected_cols<<<"$columns";
    
    for i in "${!selected_cols[@]}"; do
        selected_cols[$i]=$(echo "${selected_cols[$i]}"|xargs);
        echo "${selected_cols[$i]}";
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
extract;
parse ;
echo "${selected_cols[@]}";
# select we,   rre   from users