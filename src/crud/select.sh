#!/bin/bash

source ./src/helpers.sh
source ./src/crud/history.sh

extract() {
    columns=$(echo $sql_query | sed -n "s/.*SELECT \(.*\) FROM.*/\1/pi")
    table=$(echo $sql_query | sed -n "s/.*FROM \([^ ]*\).*/\1/pi")
    cur_table=$table
    where_clouse=$(echo $sql_query | sed -n "s/.*WHERE \(.*\)/\1/pi")
    where_clouse=$(echo $where_clouse | sed 's/[[:space:]]*;$//')
}

parse() {
    if [[ "$columns" == "*" ]]; then
        selected_cols=("${col_arr[@]}")
    else
        IFS=',' read -ra selected_cols <<<"$columns"
    fi

    for i in "${!selected_cols[@]}"; do
        selected_cols[$i]=$(echo "${selected_cols[$i]}" | xargs)
    done

    for col in "${selected_cols[@]}"; do
        if [[ ! -v col_index_dic[$col] ]]; then
            gum style --foreground 196 "Error: Column '$col' does not exist"
            return 1
        fi
    done

    if [[ $where_clouse =~ ([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*(=|!=|>|<|>=|<=)[[:space:]]*(.*) ]]; then
        where_col="${BASH_REMATCH[1]}"
        where_op="${BASH_REMATCH[2]}"
        where_val="${BASH_REMATCH[3]}"
    fi
}

evaluate_where() {
    local row_val=$1
    local op=$2
    local expected_val=$3
    local data_type=$4

    case $op in
    "=")
        [[ "$row_val" == "$expected_val" ]]
        ;;
    "!=")
        [[ "$row_val" != "$expected_val" ]]
        ;;
    ">")
        if [[ "$data_type" == "int" ]]; then
            ((row_val > $expected_val))
        else
            [[ "$row_val" > "$expected_val" ]]
        fi
        ;;
    "<")
        if [[ "$data_type" == "int" ]]; then
            ((row_val < $expected_val))
        else
            [[ "$row_val" < "$expected_val" ]]
        fi
        ;;
    ">=")
        if [[ "$data_type" == "int" ]]; then
            ((row_val >= $expected_val))
        else
            [[ "$row_val" > "$expected_val" ]] || [[ "$row_val" == "$expected_val" ]]
        fi
        ;;
    "<=")
        if [[ "$data_type" == "int" ]]; then
            ((row_val <= $expected_val))
        else
            [[ "$row_val" < "$expected_val" ]] || [[ "$row_val" == "$expected_val" ]]
        fi
        ;;
    esac
}

execute_query() {
    for col in "${selected_cols[@]}"; do
        if [[ ! -v col_index_dic[$col] ]]; then
            gum style --foreground 196 "Error: Column '$col' does not exist"
            return 1
        fi
    done

    for col in "${selected_cols[@]}"; do
        selected_col_indeces+=("${col_index_dic[$col]}")
    done
    if [[ -n $where_col ]]; then
        where_idx=("${col_index_dic[$where_col]}")
    fi

    header=$(
        IFS=','
        echo "${selected_cols[*]}"
    )
    final_res+=("$header")
    while read -r row; do
        IFS=',' read -ra row_vals <<<"$row"
        cur_row_val="${row_vals[$where_idx]}"
        filtered=()

        if [[ -n $where_col ]]; then
            if ! evaluate_where "$cur_row_val" "$where_op" "$where_val" "${col_datatype_dic[$where_col]}"; then
                continue
            fi
        fi
        for idx in "${selected_col_indeces[@]}"; do
            filtered+=("${row_vals[$idx]}")
        done

        data=$(
            IFS=','
            echo "${filtered[*]}"
        )
        final_res+=("$data")
    done <"$data_file"
}

display() {
    if [ ${#final_res[@]} -eq 0 ]; then
        gum style --foreground 82 "Empty result set (0 rows)"
        return
    fi
    declare -a header_cols

    IFS=',' read -ra header_cols <<<"${final_res[0]}"

    col_width=()
    for col in "${header_cols[@]}"; do
        col_width+=("${#col}")
    done

    for ((i = 1; i < ${#final_res[@]}; i++)); do
        IFS=',' read -ra row_data <<<"${final_res[$i]}"

        for j in "${!row_data[@]}"; do
            val=${row_data[$j]}
            len=${#val}
            [[ $val == "null" ]] && val="NULL"

            ((len > col_width[j])) && col_width[$j]=$len
        done
    done

    for i in "${!col_width[@]}"; do
        ((col_width[i] = col_width[i] + 2))
    done

    print_separator() {
        echo -n "+"
        for w in "${col_width[@]}"; do
            printf "%${w}s" "" | tr ' ' '-'
            echo -n "+"
        done
        echo ""
    }

    print_separator

    echo -n "|"
    for i in "${!header_cols[@]}"; do
        printf " %-$((col_width[$i] - 1))s" "${header_cols[$i]}"
        echo -n "|"
    done
    echo ""

    print_separator

    for ((i = 1; i < ${#final_res[@]}; i++)); do
        IFS=',' read -ra row_data <<<"${final_res[$i]}"

        echo -n "|"
        for j in "${!row_data[@]}"; do
            val=${row_data[$j]}
            len=${#val}
            [[ $val == "null" ]] && val="NULL"
            printf " %-$((col_width[$j] - 1))s" "$val"
            echo -n "|"
        done
        echo ""
    done
    print_separator
    gum style --foreground 82 "$((${#final_res[@]} - 1)) rows in set"
}

main_select() {

    clear
    echo "OurSQL Query Interface"
    echo "Commands: \q or exit to quit, \h for history, clear to clear screen"
    echo "Use UP/DOWN arrow keys to navigate history"
    echo ""

    while true; do
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

        read_with_history "OurSql> "
        sql_query="$current_line"
        case "${sql_query,,}" in
        exit | q | quit | bye | \\q)
            break
            ;;
        clear)
            clear
            continue
            ;;
        \h | history)
            echo "Query History:"
            for i in "${!history_arr[@]}"; do
                echo "$i: ${history_arr[$i]}"
            done
            continue
            ;;
        "")
            continue
            ;;
        esac

        sql_query=$(echo "$sql_query" | tr -s ' ')
        sql_query=$(echo "$sql_query" | sed 's/[[:space:]]*;$//')

        set -f
        extract
        if [[ -z "$table" ]]; then 
            echo "Error: invalid query syntax, missing table name"
            continue
        fi
        meta_file="$dbms_dir/$cur_db/$cur_table.meta"
        data_file="$dbms_dir/$cur_db/$cur_table.txt"

        if [[ ! -f "$meta_file" ]] || [[ ! -f "$data_file" ]]; then
            echo "Error: table '$cur_table' does not exist"
            continue
        fi

        populate_table_metadata
        parse || {
            set +f
            continue
        }
        execute_query || {
            set +f
            continue
        }
        display

        set +f
    done
}

main_select
sleep 1
. ./src/after_connection.sh
