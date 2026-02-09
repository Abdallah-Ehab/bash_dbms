#!/bin/bash

declare -a history_arr
declare -i history_idx=$(( ${#history_arr[@]} - 1 ));
declare -i history_max=100

push_to_history(){
    local query="$1"
    if [[ -z "$query" ]]; then
        return
    fi

    if [[ "${#history_arr[@]}" -gt 0 ]] && [[ "${history_arr[-1]}" == "$query" ]]; then
        return 
    fi
    history_arr+=("$query");
    if [[ "${#history_arr[@]}" -gt $history_max ]]; then
        history_arr=("${history_arr[@]:1}"); 
    fi
    history_idx=${#history_arr[@]};

 }

navigate_history(){
    local direction="$1";

    if [[ "$direction" == "up" ]]; then
        if [[ $history_idx -gt 0 ]]; then
            history_idx=$((history_idx - 1));
        fi
    elif [[ "$direction" == "down" ]]; then
        if [[ $history_idx -lt "${#history_arr[@]}" ]]; then
            ((history_idx++));

        fi
    fi

    if [[ $history_idx -ge 0 ]] && [[ $history_idx -lt "${#history_arr[@]}" ]]; then
        current_line="${history_arr[$history_idx]}";
    else
        current_line="";
    fi

}

read_with_history(){
    local prompt="$1";
    current_line="";
    local line="";

    history_idx=${#history_arr[@]};
    printf "%s" "$prompt";

    while IFS= read -rsn1 char; do
        # Handle arrow keys (escape sequences)
        if [[ $char == $'\x1b' ]]; then
            read -rsn2 -t .1 rest
            if [[ $rest == "[A" ]]; then
                navigate_history "up"
                printf $'\r\033[K';
                printf "%s %s" "${prompt}" "$current_line";
            elif [[ $rest == "[B" ]]; then
                navigate_history "down"
                printf $'\r\033[K';                
                printf "%s %s" "${prompt}" "$current_line";

            elif [[ $rest == "[C" ]]; then
                :
            elif [[ $rest == "[D" ]]; then
                :
            fi
        # Handle backspace
        elif [[ $char == $'\x7f' ]]; then
            if [[ -n "$current_line" ]]; then
                current_line="${current_line%?}" # Remove the last character
                printf $'\r\033[K'; # Clear the line from the cursor to the end
                printf "%s %s" "${prompt}" "$current_line"; # Reprint the prompt and the current line
            fi
        
        # Handle Enter key
        elif [[ $char == "" ]]; then
            echo "";
            line="$current_line";
            push_to_history "$line";
            break
        # Handle regular characters
        else
            current_line+="$char";
            echo -n "$char";
        fi
    done

    # echo "$line";

}