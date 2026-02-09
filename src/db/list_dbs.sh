#!/bin/bash

if [ -d "$dbms_dir" ] && [ "$(ls -A "$dbms_dir" 2>/dev/null)" ]; then
    db_list=$(ls -1 "$dbms_dir")

    # Display databases using gum style
    gum style --border double --border-foreground 212 --padding "1 2" --align center "$(printf "Databases:\n%s" "$db_list")"
else
    gum style --foreground 196 --border double --padding "1 2" --align center "No databases found"
fi

sleep 2
. ./dbms.sh
