#!/bin/bash

if [ -d "$dbms_dir/$cur_db" ] && [ "$(ls -A "$dbms_dir/$cur_db" 2>/dev/null)" ]; then
    echo "Tables in $cur_db:"

    #print tables without .meta, .txt
    for file in "$dbms_dir/$cur_db"/*.txt; do
        if [ -f "$file" ]; then
            table_name=$(basename "$file" .txt) # basename ==> get file name only
            echo "$table_name"
        fi
    done

else
    echo "No tables found"
fi

echo ""
echo ""
. ./src/after_connection.sh
