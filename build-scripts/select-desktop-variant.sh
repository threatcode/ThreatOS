#!/bin/bash

set -e

# Source the desktop variants configuration
source "$(dirname "${BASH_SOURCE[0]}")/../config/desktop-variants.conf"

# Function to display the variant selection menu
show_variant_menu() {
    echo "Available desktop variants:"
    for i in "${!VARIANT_NAMES[@]}"; do
        echo "  $((i+1)). ${VARIANT_DISPLAY_NAMES[$i]} (${VARIANT_NAMES[$i]})"
    done
    echo -n "Select a variant [1-${#VARIANT_NAMES[@]}, default: ${DEFAULT_VARIANT}]: "
}

# Function to get the variant name from the user
select_variant() {
    local variant=""
    
    # If variant is provided as an argument, use it
    if [ $# -ge 1 ]; then
        variant="$1"
        # Check if the provided variant is valid
        for i in "${!VARIANT_NAMES[@]}"; do
            if [ "${VARIANT_NAMES[$i]}" = "$variant" ]; then
                SELECTED_VARIANT="$variant"
                SELECTED_PACKAGES="${VARIANT_PACKAGES[$i]}"
                SELECTED_DESKTOP="${VARIANT_DESKTOPS[$i]}"
                return 0
            fi
        done
        echo "[!] Invalid variant: $variant"
    fi
    
    # If we get here, either no variant was provided or it was invalid
    # Show the menu and get user input
    while true; do
        show_variant_menu
        read -r selection
        
        # Use default if no input
        if [ -z "$selection" ]; then
            for i in "${!VARIANT_NAMES[@]}"; do
                if [ "${VARIANT_NAMES[$i]}" = "$DEFAULT_VARIANT" ]; then
                    SELECTED_VARIANT="$DEFAULT_VARIANT"
                    SELECTED_PACKAGES="${VARIANT_PACKAGES[$i]}"
                    SELECTED_DESKTOP="${VARIANT_DESKTOPS[$i]}"
                    return 0
                fi
            done
        fi
        
        # Check if the input is a valid number
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#VARIANT_NAMES[@]} ]; then
            local index=$((selection-1))
            SELECTED_VARIANT="${VARIANT_NAMES[$index]}"
            SELECTED_PACKAGES="${VARIANT_PACKAGES[$index]}"
            SELECTED_DESKTOP="${VARIANT_DESKTOPS[$index]}"
            return 0
        else
            echo "[!] Invalid selection. Please enter a number between 1 and ${#VARIANT_NAMES[@]}."
        fi
    done
}

# Main execution
if [ "$1" = "--list" ]; then
    # List all available variants
    for i in "${!VARIANT_NAMES[@]}"; do
        echo "${VARIANT_NAMES[$i]}: ${VARIANT_DISPLAY_NAMES[$i]}"
    done
    exit 0
elif [ "$1" = "--get-packages" ] && [ -n "$2" ]; then
    # Get packages for a specific variant
    for i in "${!VARIANT_NAMES[@]}"; do
        if [ "${VARIANT_NAMES[$i]}" = "$2" ]; then
            echo "${VARIANT_PACKAGES[$i]}"
            exit 0
        fi
    done
    echo "[!] Unknown variant: $2" >&2
    exit 1
elif [ "$1" = "--get-desktop" ] && [ -n "$2" ]; then
    # Get desktop session for a specific variant
    for i in "${!VARIANT_NAMES[@]}"; do
        if [ "${VARIANT_NAMES[$i]}" = "$2" ]; then
            echo "${VARIANT_DESKTOPS[$i]}"
            exit 0
        fi
    done
    echo "[!] Unknown variant: $2" >&2
    exit 1
else
    # Interactive selection
    select_variant "$@"
    echo "${SELECTED_VARIANT} ${SELECTED_PACKAGES} ${SELECTED_DESKTOP}"
fi
