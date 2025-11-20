#!/bin/bash

# ThreatOS Package Update Monitor
# Monitors upstream repositories for package updates

set -euo pipefail

# Load common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# Default values
CONFIG_FILE="${SCRIPT_DIR}/update-monitor.conf"
LOG_FILE="/var/log/threatos/update-monitor.log"
CHECK_INTERVAL=86400  # Default: 24 hours
NOTIFY_EMAIL=""
PACKAGE_LIST=()

# Load configuration if exists
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

# Check for updates on GitHub
check_github_update() {
    local repo=$1
    local current_version=$2
    local latest_version
    
    log "INFO" "Checking GitHub repository: $repo"
    
    # Use GitHub API to get latest release
    latest_version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | 
                   grep '"tag_name":' | 
                   sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$latest_version" ]; then
        log "ERROR" "Failed to get latest version for $repo"
        return 1
    fi
    
    if [ "$latest_version" != "$current_version" ]; then
        log "UPDATE" "New version available for $repo: $current_version -> $latest_version"
        return 0
    fi
    
    log "INFO" "$repo is up to date ($current_version)"
    return 1
}

# Check for updates on PyPI
check_pypi_update() {
    local package=$1
    local current_version=$2
    local latest_version
    
    log "INFO" "Checking PyPI package: $package"
    
    latest_version=$(curl -s "https://pypi.org/pypi/$package/json" | 
                   grep -oP '"latest_version": "\K[^"]+')
    
    if [ -z "$latest_version" ]; then
        log "ERROR" "Failed to get latest version for PyPI package: $package"
        return 1
    fi
    
    if [ "$latest_version" != "$current_version" ]; then
        log "UPDATE" "New version available for $package: $current_version -> $latest_version"
        return 0
    fi
    
    log "INFO" "$package is up to date ($current_version)"
    return 1
}

# Main monitoring function
monitor_updates() {
    log "INFO" "Starting package update check"
    
    # Example package list (should be loaded from config)
    # Format: "source:package:current_version"
    local packages=(
        "github:golang/go:1.21.0"
        "pypi:requests:2.31.0"
    )
    
    local updates_available=0
    
    for pkg in "${packages[@]}"; do
        IFS=':' read -r source package version <<< "$pkg"
        
        case $source in
            github)
                if check_github_update "$package" "$version"; then
                    updates_available=$((updates_available + 1))
                fi
                ;;
            pypi)
                if check_pypi_update "$package" "$version"; then
                    updates_available=$((updates_available + 1))
                fi
                ;;
            *)
                log "WARNING" "Unsupported package source: $source"
                ;;
        esac
    done
    
    if [ $updates_available -gt 0 ]; then
        log "INFO" "Found $updates_available package(s) with updates available"
        # Add notification logic here (email, systemd, etc.)
    else
        log "INFO" "All packages are up to date"
    fi
}

# Main execution
while true; do
    monitor_updates
    sleep "$CHECK_INTERVAL"
done
