#!/bin/bash


# this is for some helper functions where the functionality I noticed were repetitive

disconnect_and_rm_curdb(){
    cur_db="";
    is_connected=false;
}

if [ "$1" -eq 1 ] && [ "$#" -eq 1 ];then
    disconnect_and_rm_curdb
    echo "disconnected ";
fi

. ./main.sh


