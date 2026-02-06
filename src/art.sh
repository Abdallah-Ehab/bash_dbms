#!/bin/bash

# Define Colors
# \033[1;36m = Bold Cyan
# \033[1;37m = Bold White
# \033[0m    = No Color (Reset)
COLOR_THEME='\033[1;36m'
COLOR_ACCENT='\033[1;37m'
NC='\033[0m'

show_logo() {
    clear
    echo -e "${COLOR_THEME}"

    # The quotes around "EOF" prevent backslash/variable issues
    # This uses the Unicode "Full Block" (█) for maximum thickness
    cat <<"EOF"
      ████████      ███      ███
     ███    ███     ████    ████
     ███    ███     █████  █████
     ██████████     ███ ████ ███
     ███    ███     ███  ██  ███
     ███    ███     ███      ███
     ███    ███     ███      ███
EOF

    echo -e "${NC}"
    echo -e "${COLOR_ACCENT}==========================================${NC}"
    echo -e " [ AM DBMS - Session Started: $(date +%H:%M:%S) ]"
    echo -e "${COLOR_ACCENT}==========================================${NC}\n"
}

# Call the function
show_logo
