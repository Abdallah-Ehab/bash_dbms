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

read -p "Enter columns (comma separated): " user_input
IFS=',' read -ra col_arr <<< "$user_input"

row_data=""

validate_col(){
    local col_value=$1
    local col_data_type=$2
    case $col_data_type in
    "int")
        if [[ $col_value =~ ^[0-9]+$ ]]; then
            row_data+=$col_value
        else
            echo "enter correct data type for col"
        fi
        ;;
    *|"varchar")
        if [[ $col_value =~ ^[a-zA-Z0-9[:space:]]+$ ]]; then
            row_data+=$col_value
        else
            echo "enter correct data type for col"
        fi
        ;;
    esac
        
}
## check if the column names are correct first:
for col in "${col_arr[@]}"; do
    is_matching="false"
    while IFS='=' read -r col_name; do
        if [[ "$col" == "$col_name" ]];then
            is_matching="true";
            break;
        fi
    if [[ $is_matching != "true" ]];then
        echo "column ($col) doesn't exist try entering a valid column";
        exit;
    fi
    done < "$dbms_dir/$cur_db/$cur_table.meta"
done

## take of the order of columns while entering data
while IFS='=' read -r col_name col_data_type; do
    is_found="false";
    for col in "${col_arr[@]}"; do
        if [[ $col == $col_name ]]; then
            is_found="true";
            break
        fi
    done
    if [[ is_found = "true" ]]; then
        read -p "enter the value of the column ($col_name)" col_value;
        validate_col $col_value $col_data_type
        row_data+=,  
    else
        row_data+="null,"
    fi
done < "$dbms_dir/$cur_db/$cur_table.meta"


row_data=$(echo "$row_data" | sed "s/,$//");
echo "$row_data" >> "$dbms_dir/$cur_db/$cur_table"


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