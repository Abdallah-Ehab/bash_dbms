#!/bin/bash

# Define colors
CYAN='\033[0;36m'
NC='\033[0m' # No Color

show_logo() {
    echo -e "${CYAN}"
    # The quotes around "EOF" are important to prevent backslash issues
    cat <<"EOF"
      /|      _______
     / |     /      /
    /  |    /  ____/ 
   / ^ |   /  /_     
  / ___|  /  __/     
 / /   | /  /____    
/_/    |/_______/    
EOF
    echo -e "${NC}"
    echo -e " [ AE DBMS - Session Started: $(date +%H:%M:%S) ]\n"
}

# Call the function
show_logo