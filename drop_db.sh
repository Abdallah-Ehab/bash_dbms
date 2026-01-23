#!/bin/bash


#this file is for the code for droppping the db aka : just deleting the db_dir

# we need to handle these edge cases 
# 1- what if the deleted db doesn't exist 
# 2- what if I drop the current dp -> I should disconnect 
# 3- what if I'm not disconnected to a db -> dropping should ask you for the name of the db
# 4- 3 has a relationship to one -> I can't drop non existent db unless I'm not connected to any db
# variables needed : $dbms_dir -> main.sh, $db_name -> connect_to_db.sh

#check if we are connected

if [ $is_connected == true ]; then
    # we will drop the current db
    [ -d "$dbms_dir/$db_name" ] && [ rm -rf "$dbms_dir/$db_name" ] || echo "ERROR: cant remove the current db is not found "
    cd $dbms_dir
else 
    # ask for the name of the db
    read -p "enter the db name" rem_db_name
    [ -d "$dbms_dir/$db_name" ] && rm -rf "$dbms_dir/$db_name"
fi