#!/bin/bash

if [ -d "$dbms_dir" ] && [ "$(ls -A "$dbms_dir" 2>/dev/null)" ]; then
    echo "Databases:"
    ls -1 "$dbms_dir"
    echo ""
else
    echo "No databases found"
fi

echo "Press Enter to continue..."
read -r

. ./dbms.sh
