#!/bin/bash

# Set strict error handling
set -o errexit  # Exit on any error
set -o nounset  # Exit on undefined variables
set -o pipefail # Catch failures in pipes

# Color definitions for error messages
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# Logging functions
log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
}

log_info() {
    echo -e "[INFO] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Error handling functions
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Required command '$1' is not installed"
        exit 1
    fi
}

check_file() {
    if [ ! -f "$1" ]; then
        log_error "File not found: $1"
        exit 1
    fi
}

check_dir() {
    if [ ! -d "$1" ]; then
        log_error "Directory not found: $1"
        exit 1
    fi
}

check_environment() {
    local var_name="$1"
    if [ -z "${!var_name:-}" ]; then
        log_error "Environment variable $var_name is not set"
        exit 1
    fi
}

# Trap to handle script errors
trap 'handle_error $? $LINENO' ERR

handle_error() {
    local exit_code=$1
    local line_no=$2
    local script_name=$(basename "${BASH_SOURCE[1]}")
    
    log_error "Error in $script_name at line $line_no: $(sed -n "${line_no}p" "${BASH_SOURCE[1]}")"
    log_error "Command exited with status $exit_code"
    
    # Print stack trace
    local frame=0
    while caller $frame; do
        ((frame++))
    done | awk '{
        printf "  at %s (%s:%d)\n", $2, $3, $1
    }' >&2
    
    exit $exit_code
}

# Function to validate input parameters
validate_parameter() {
    local param_name="$1"
    local param_value="${!param_name:-}"
    local pattern="$2"
    local error_msg="$3"
    
    if [[ ! "$param_value" =~ $pattern ]]; then
        log_error "Invalid value for $param_name: $error_msg"
        exit 1
    fi
}

# Function to check if a value is in a list
value_in_list() {
    local value="$1"
    shift
    for item in "$@"; do
        if [ "$value" = "$item" ]; then
            return 0
        fi
    done
    return 1
}
