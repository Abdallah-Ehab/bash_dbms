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


##my plan for enforcing primary key constraint (uniqness) is :
## 1- when the user enter the columns primary key field is added to the meta file issue for nabil
## 2- primary key field will be in the form of : primary_key: col1,col2 ex: primary_key : id,name,...
## 3- we parse primary key fields in a hashset or array but better be a hashset or map with key = column_name and value = index or order of hte column : priamry_key_set[id] = 1, primary_key_set[name] =1 etc...
## 4- while the uesr is entering the values for the columns if the col exists in the primary_key_set
## the value should be appended to the primary_key_str
## 5- the primary_key_string can be used in the unique_set like this unique_set[$primary_key_str]
## example if the primary keys are id,name and the user entered 1,abdallah and 2,omar
## then the unique_set["1,abdallah"] = 1, unique_set["2,omar"] = 1
## where the primary_key_string in the first phase = "1,abdallah" and in the second phase = "2,omar"
## then if the user attempts to enter the values : 1,abdallah again throw error : violate unique constraint

# Prompt user for table name if not already set
if [ -z "$cur_table" ]; then
    read -p "Enter table name: " cur_table
fi

# Set meta_file and data_file paths
meta_file="$dbms_dir/$cur_db/$cur_table.meta"
data_file="$dbms_dir/$cur_db/$cur_table.txt"

# Check if table exists
if [ ! -f "$data_file" ] || [ ! -f "$meta_file" ]; then
    echo "ERROR: Table '$cur_table' not found"
    . ./after_connection.sh
    exit 1
fi

declare -A hashmap
declare -a col_arr
declare -a primary_key_cols
declare -A is_pk_index
declare -A primary_key_set

# 2. Parse meta file: Get column types, order, and identify PK names
while IFS='=' read -r key value; do
    if [[ "$key" == "primary_key" ]]; then
        IFS=',' read -ra primary_key_cols <<< "$value"
    else
        hashmap["$key"]="$value"
        col_arr+=("$key")
    fi
done < "$meta_file"

# 3. Map column indices to PK status
# This tells us: "Is column index 0 a PK? Is index 1 a PK?"
for i in "${!col_arr[@]}"; do
    for pk_name in "${primary_key_cols[@]}"; do
        if [[ "${col_arr[$i]}" == "$pk_name" ]]; then
            is_pk_index[$i]=1
        fi
    done
done


if [[ -f "$data_file" ]]; then
    while read -r line; do
        IFS=',' read -ra row_vals <<< "$line"
        pk_val_build=()
        for i in "${!row_vals[@]}"; do
            if [[ -v is_pk_index[$i] ]]; then
                pk_val_build+=("${row_vals[$i]}")
            fi
        done
        # Join primary key values with commas to create the unique key
        key_str=$(IFS=,; echo "${pk_val_build[*]}")
        primary_key_set["$key_str"]=1
    done < "$data_file"
fi

validate_col() {
    local value="$1"
    local type="$2"
    case "$type" in
        int) [[ $value =~ ^[0-9]+$ ]] ;;
        varchar*) [[ $value =~ ^[a-zA-Z0-9[:space:]]+$ ]] ;;
        *) return 0 ;;
    esac
}


declare -A target_cols_set
read -rp "Enter the col names separated by , (e.g. id,name): " user_input
IFS=',' read -ra target_cols <<< "$user_input"

for col in "${target_cols[@]}"; do
    if [[ ! -v hashmap["$col"] ]]; then
        echo "Error: Column ($col) doesn't exist."; exit 1
    fi
    target_cols_set[$col]=1
done

# 6. build the pk_string
declare -a row_data_arr
declare -a current_pk_vals

for col in "${col_arr[@]}"; do
    if [[ -v target_cols_set["$col"] ]]; then
        read -rp "Enter value for $col: " col_value
        validate_col "$col_value" "${hashmap[$col]}" || { echo "Validation failed"; exit 1; }
        
        # Check if this column is a PK
        for pk_name in "${primary_key_cols[@]}"; do
            if [[ "$col" == "$pk_name" ]]; then
                current_pk_vals+=("$col_value")
            fi
        done
        row_data_arr+=("$col_value")
    else
        row_data_arr+=("null")
    fi
done


new_pk_str=$(IFS=,; echo "${current_pk_vals[*]}")

if [[ -v primary_key_set["$new_pk_str"] ]]; then
    echo "Error: Primary Key violation! ($new_pk_str) already exists."
    exit 1
fi


echo "$(IFS=,; echo "${row_data_arr[*]}")" >> "$data_file"
echo "Record inserted successfully."