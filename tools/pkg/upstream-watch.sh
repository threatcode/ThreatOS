#!/bin/bash
# @upstream-watch - Check for upstream updates for ThreatOS packages

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UPSTREAM_WATCH_DIR="${SCRIPT_DIR}/../upstream-watch"
PACKAGE_LIST="${UPSTREAM_WATCH_DIR}/package-list"

# Check if required tools are installed
check_dependencies() {
    local missing=()
    
    for cmd in wget devscripts xmlstarlet dctrl-tools git uscan; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "The following required tools are missing:"
        for cmd in "${missing[@]}"; do
            echo "  - $cmd"
        done
        echo ""
        echo "Install them with:"
        echo "  sudo apt update && sudo apt install -y ${missing[*]}"
        return 1
    fi
    return 0
}

# Update the package list from the repository
update_package_list() {
    echo "Updating package list from the repository..."
    cd "${SCRIPT_DIR}/../../"
    
    # Find all packages in the packages directory
    find packages -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort > "${PACKAGE_LIST}.new"
    
    # Check if there are any changes
    if ! cmp -s "${PACKAGE_LIST}" "${PACKAGE_LIST}.new"; then
        mv "${PACKAGE_LIST}.new" "${PACKAGE_LIST}"
        echo "Package list updated with $(wc -l < "${PACKAGE_LIST}") packages"
    else
        rm -f "${PACKAGE_LIST}.new"
        echo "No changes to package list"
    fi
}

# Run the upstream watch check
run_upstream_watch() {
    echo "Running upstream watch check..."
    cd "${UPSTREAM_WATCH_DIR}"
    
    # Create work directory if it doesn't exist
    mkdir -p work
    
    # Run the upstream watch script
    ./upstream-watch
    
    # Check if there are any updates
    if [ -s "work/report" ]; then
        echo -e "\n=== Updates Available ==="
        cat work/report
        echo -e "\nFor more details, check the full report in ${UPSTREAM_WATCH_DIR}/work/"
    else
        echo -e "\nAll packages are up to date!"
    fi
}

# Main function
main() {
    echo "=== ThreatOS Upstream Watch ==="
    
    # Check if the upstream-watch directory exists
    if [ ! -d "${UPSTREAM_WATCH_DIR}" ]; then
        echo "Error: upstream-watch directory not found at ${UPSTREAM_WATCH_DIR}"
        echo "Please make sure you're running this from the ThreatOS repository root"
        exit 1
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Update package list
    update_package_list
    
    # Run upstream watch
    run_upstream_watch
}

# Run the main function
main "$@"
