#!/bin/bash
# common.sh - Common functions and variables for ThreatOS build scripts

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if running as root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for required dependencies
check_dependencies() {
    log_info "Checking for required dependencies..."
    
    local missing_deps=()
    local dep
    
    # List of required commands
    local required_commands=(
        "debootstrap"
        "wget"
        "tar"
        "gzip"
        "sudo"
        "chroot"
        "mount"
        "umount"
        "losetup"
        "parted"
        "kpartx"
        "qemu-img"
        "rsync"
    )
    
    # Check each command
    for cmd in "${required_commands[@]}"; do
        if ! command_exists "$cmd"; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for additional architecture-specific dependencies
    case "$ARCH" in
        arm64)
            if ! command_exists "qemu-aarch64-static"; then
                missing_deps+=("qemu-user-static (for arm64 support)")
            fi
            ;;
    esac
    
    # Print missing dependencies if any
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "The following dependencies are missing:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo -e "\nPlease install them using your package manager:"
        echo "  Debian/Ubuntu: sudo apt-get install ${missing_deps[*]}"
        echo "  RHEL/CentOS:   sudo yum install ${missing_deps[*]}"
        echo "  Arch Linux:    sudo pacman -S ${missing_deps[*]}"
        exit 1
    fi
    
    log_success "All dependencies are installed"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up..."
    # Add cleanup code here
}

# Set up trap for cleanup
trap cleanup EXIT
