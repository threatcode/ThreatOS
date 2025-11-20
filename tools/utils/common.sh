#!/bin/bash

# Common utilities for ThreatOS packaging tools

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "This script must be run as root"
        exit 1
    fi
}

# Check if directory exists and is writable
check_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        error "Directory does not exist: $dir"
        return 1
    fi
    
    if [ ! -w "$dir" ]; then
        error "No write permission for directory: $dir"
        return 1
    fi
    
    return 0
}

# Load configuration
load_config() {
    local config_file="${SCRIPT_DIR}/../config/config.ini"
    
    if [ -f "$config_file" ]; then
        # shellcheck source=/dev/null
        source "$config_file"
    else
        warn "Configuration file not found: $config_file"
    fi
}

# Initialize environment
init_environment() {
    # Load configuration
    load_config
    
    # Set default values if not set
    BUILD_DIR="${BUILD_DIR:-${SCRIPT_DIR}/../../build}"
    PKG_DIR="${PKG_DIR:-${SCRIPT_DIR}/../../packages}"
    
    # Create necessary directories
    mkdir -p "$BUILD_DIR"
    mkdir -p "$PKG_DIR"
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--version)
                echo "ThreatOS Packaging Tools v0.1.0"
                exit 0
                ;;
            *)
                # Handle other arguments in the specific script
                break
                ;;
        esac
    done
}

# Display usage information
usage() {
    echo "Usage: $(basename "$0") [options]"
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo "  -v, --version   Show version information"
}
