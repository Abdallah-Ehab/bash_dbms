#!/bin/bash

## this file is for inserting into the database 

# how are we going to insert into the database 
# simply we will write the data into the data file in the data 
# refer to the table_structure.txt file
# data will be in the form of : col1,col2,col3 -> row
# example : employee table : id,name,age,salary,department,ssn etc..


## the problem is how to take the input from the user 
## and how to parse the input
## we can ask the user to enter the fields field by field 
## this is not the best user experience though 
## honestly I don't know
# id = int
# name = varchar(45)
## if we use hash map instead of that we would do it like that for example :
## there are columns : id, first_name,last_name,salary,bdate
## the user enters the columns : first_name,salary
## the user then enter the values of these columns : "Ehab",1000
## the data should be : null,Ehab,null,1000,null
# so we can use a hashmap to check if the column the user entered exist:
## hashmap[id] = int , hashmap[first_name]=varchar(45), hashmap[last_name]=varchar(45) etc...
## but what about the order we could just go over each column and ask the user to enter it's value 
## we 2rei7 dema8y we 5alas
## or we could do it the way I'm doing right now with some tweaking
## for order we can use array
## also what about the primary keys
## we may add primary key map like this : primary_key[id] = []
## but can the key be an array like this : primary_key[[id,name,etc]] = []
## we could also use a set like this : primar_key{[1,abdallah,1000],[2,omar,2000]} so if the user enters [1,abdallah,1000] again for example it gives an error


## hashmap[col_name]=datatype
## col_arr = [col1,col2,col3,...coln] this is for ordered columns

validate_col() {
    local value="$1"
    local type="$2"

    case "$type" in
        int)
            [[ $value =~ ^[0-9]+$ ]]
            ;;
        varchar)
            [[ $value =~ ^[a-zA-Z0-9[:space:]]+$ ]]
            ;;
        *)
            return 1
            ;;
    esac
}



declare -A hashmap;
declare -A target_cols_set;
declare -a col_arr;
declare -a row_data_arr;


meta_file="$dbms_dir/$cur_db/$cur_table.meta"
data_file="$dbms_dir/$cur_db/$cur_table"

while IFS='=' read -r col_name data_type; do
    hashmap["$col_name"]="$data_type";
    col_arr+=("$col_name")
done < "$meta_file"


read -rp "enter the col names separated by ," user_input
IFS=',' read -ra target_cols <<< "$user_input";

for col in "${target_cols[@]}"; do
    if [[ ! -v hashmap["$col"] ]]; then
        echo "col ($col) doesn't exist please enter valid columns";
        exit;
    else
        target_cols_set[$col]=1
    fi
done

for col in "${col_arr[@]}"; do
    if [[ -v target_cols_set["$col"] ]]; then
        read -rp "enter the value " col_value;
        validate_col "$col_value" "${hashmap[$col]}" || {
        echo "something is wrong I can feel it"; 
        exit 1;}
        row_data_arr+=("$col_value")
    else
        row_data_arr+=(null)
    fi
done

IFS=',' row_data="${row_data_arr[*]}"
echo "$row_data" >> "$data_file"

