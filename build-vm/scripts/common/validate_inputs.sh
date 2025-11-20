#!/bin/bash

# Source the error handling library
source "$(dirname "${BASH_SOURCE[0]}")/error_handling.sh"

# Validate architecture
validate_architecture() {
    local arch="$1"
    if ! value_in_list "$arch" $SUPPORTED_ARCHITECTURES; then
        log_error "Unsupported architecture: $arch. Supported: $SUPPORTED_ARCHITECTURES"
        exit 1
    fi
}

# Validate branch
validate_branch() {
    local branch="$1"
    if ! value_in_list "$branch" $SUPPORTED_BRANCHES; then
        log_error "Unsupported branch: $branch. Supported: $SUPPORTED_BRANCHES"
        exit 1
    fi
}

# Validate desktop environment
validate_desktop() {
    local desktop="$1"
    if ! value_in_list "$desktop" $SUPPORTED_DESKTOPS; then
        log_error "Unsupported desktop: $desktop. Supported: $SUPPORTED_DESKTOPS"
        exit 1
    fi
}

# Validate format
validate_format() {
    local format="$1"
    if ! value_in_list "$format" $SUPPORTED_FORMATS; then
        log_error "Unsupported format: $format. Supported: $SUPPORTED_FORMATS"
        exit 1
    fi
}

# Validate variant
validate_variant() {
    local variant="$1"
    if ! value_in_list "$variant" $SUPPORTED_VARIANTS; then
        log_error "Unsupported variant: $variant. Supported: $SUPPORTED_VARIANTS"
        exit 1
    fi
}

# Validate toolset
validate_toolset() {
    local toolset="$1"
    if ! value_in_list "$toolset" $SUPPORTED_TOOLSETS; then
        log_error "Unsupported toolset: $toolset. Supported: $SUPPORTED_TOOLSETS"
        exit 1
    fi
}

# Validate hostname
validate_hostname() {
    local hostname="$1"
    if ! [[ "$hostname" =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$ ]]; then
        log_error "Invalid hostname: $hostname. Must be 1-63 chars, alphanumeric with hyphens"
        exit 1
    fi
}

# Validate size
validate_size() {
    local size="$1"
    if ! [[ "$size" =~ ^[0-9]+$ ]] || [ "$size" -lt 1 ] || [ "$size" -gt 1000 ]; then
        log_error "Invalid size: $size. Must be a number between 1 and 1000 (GB)"
        exit 1
    fi
}

# Validate mirror URL
validate_mirror() {
    local mirror="$1"
    if ! [[ "$mirror" =~ ^https?://.+/$ ]]; then
        log_error "Invalid mirror URL: $mirror. Must start with http:// or https:// and end with /"
        exit 1
    fi
}

# Validate username and password
validate_credentials() {
    local username="$1"
    local password="$2"
    
    # Check username
    if ! [[ "$username" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
        log_error "Invalid username: $username. Must start with a letter or _ and contain only a-z, 0-9, _ and -"
        exit 1
    fi
    
    # Check password (basic check for non-empty)
    if [ -z "$password" ]; then
        log_error "Password cannot be empty"
        exit 1
    fi
}

# Validate all inputs
validate_all_inputs() {
    log_info "Validating build configuration..."
    
    # Validate required parameters
    [ -z "$ARCH" ] && ARCH=$DEFAULT_ARCH
    [ -z "$BRANCH" ] && BRANCH=$DEFAULT_BRANCH
    [ -z "$DESKTOP" ] && DESKTOP=$DEFAULT_DESKTOP
    [ -z "$FORMAT" ] && FORMAT="raw"
    [ -z "$HOSTNAME" ] && HOSTNAME=$DEFAULT_HOSTNAME
    [ -z "$KEYBOARD" ] && KEYBOARD=$DEFAULT_KEYBOARD
    [ -z "$LOCALE" ] && LOCALE=$DEFAULT_LOCALE
    [ -z "$MIRROR" ] && MIRROR=$DEFAULT_MIRROR
    [ -z "$TIMEZONE" ] && TIMEZONE=$DEFAULT_TIMEZONE
    [ -z "$TOOLSET" ] && TOOLSET=$DEFAULT_TOOLSET
    [ -z "$VARIANT" ] && VARIANT=$DEFAULT_VARIANT
    [ -z "$SIZE" ] && SIZE=86
    
    # Validate values
    validate_architecture "$ARCH"
    validate_branch "$BRANCH"
    validate_desktop "$DESKTOP"
    validate_format "$FORMAT"
    validate_variant "$VARIANT"
    validate_toolset "$TOOLSET"
    validate_hostname "$HOSTNAME"
    validate_size "$SIZE"
    validate_mirror "$MIRROR"
    
    # Validate credentials if provided
    if [ -n "$USERNAME" ] && [ -n "$PASSWORD" ]; then
        validate_credentials "$USERNAME" "$PASSWORD"
    fi
    
    log_info "All inputs validated successfully"
}
