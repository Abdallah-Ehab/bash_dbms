#!/bin/bash

#this script will be the main dbms script
#I don't know what it handles yet but of course it handles something xD

#some shared variables among all files
db_dir="$HOME"/db_dir;


check_if_dir_exists(){
    [ -d $db_dir ] || mkdir -p $db_dir
    
}


#function for creating database