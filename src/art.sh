#!/bin/bash

show_logo() {
    clear

    # Create a styled logo box using gum
    LOGO=$(
        cat <<'EOF'
      ████████      ███      ███
     ███    ███     ████    ████
     ███    ███     █████  █████
     ██████████     ███ ████ ███
     ███    ███     ███  ██  ███
     ███    ███     ███      ███
     ███    ███     ███      ███
EOF
    )

    # Display logo with gum style
    gum style --border double --border-foreground 212 --padding "1 2" "$LOGO"

    # Display header info
    gum style --foreground 212 --align center "AM DBMS - Session Started: $(date +%H:%M:%S)"
    echo ""
}

# Call the function
show_logo
