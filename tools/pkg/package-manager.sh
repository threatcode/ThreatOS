#!/bin/bash

# ThreatOS Package Manager
# A helper script for managing ThreatOS packages

set -euo pipefail

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../utils/common.sh"

# Default values
PACKAGE_NAME=""
VERSION=""
ACTION=""
BUILD_DIR="${SCRIPT_DIR}/../../build"
PKG_DIR="${SCRIPT_DIR}/../../packages"

# Display usage information
usage() {
    echo "ThreatOS Package Manager"
    echo "Usage: $0 <action> [options]"
    echo ""
    echo "Actions:"
    echo "  build <package> [version]  Build a package"
    echo "  install <package>         Install a package"
    echo "  update <package>          Update a package"
    echo "  remove <package>          Remove a package"
    echo "  list                      List available packages"
    echo "  clean                     Clean build directory"
    echo ""
    echo "Options:
    -h, --help      Show this help message
    -v, --version   Show version"
}

# Parse command line arguments
parse_args() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    ACTION="$1"
    shift

    case "$ACTION" in
        build|install|update|remove)
            if [ $# -lt 1 ]; then
                error "Package name is required for action '$ACTION'"
                usage
                exit 1
            fi
            PACKAGE_NAME="$1"
            shift
            
            if [ "$ACTION" = "build" ] && [ $# -gt 0 ]; then
                VERSION="$1"
                shift
            fi
            ;;
        list|clean)
            # No additional arguments needed
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -v|--version)
            echo "ThreatOS Package Manager v0.1.0"
            exit 0
            ;;
        *)
            error "Unknown action: $ACTION"
            usage
            exit 1
            ;;
    esac
}

# Build a package
build_package() {
    local pkg_dir="${PKG_DIR}/${PACKAGE_NAME}"
    local build_dir="${BUILD_DIR}/${PACKAGE_NAME}"
    
    info "Building package: ${PACKAGE_NAME}${VERSION:+ version ${VERSION}}"
    
    # Create build directory
    mkdir -p "${build_dir}"
    
    # Check if package exists
    if [ ! -d "${pkg_dir}" ]; then
        error "Package '${PACKAGE_NAME}' not found in ${PKG_DIR}"
        return 1
    fi
    
    # Copy package files to build directory
    cp -r "${pkg_dir}/"* "${build_dir}/"
    
    # Run build script if it exists
    if [ -f "${pkg_dir}/build.sh" ]; then
        info "Running build script..."
        (cd "${build_dir}" && ./build.sh "${VERSION}")
    fi
    
    # Package the build
    info "Creating package archive..."
    local pkg_file="${PACKAGE_NAME}-${VERSION:-$(date +%Y%m%d)}.tar.gz"
    (cd "${build_dir}" && tar -czf "../${pkg_file}" .)
    
    success "Package built: ${BUILD_DIR}/${pkg_file}"
}

# Install a package
install_package() {
    # Implementation for package installation
    info "Installing package: ${PACKAGE_NAME}"
    # Add installation logic here
    success "Package installed: ${PACKAGE_NAME}"
}

# Update a package
update_package() {
    # Implementation for package update
    info "Updating package: ${PACKAGE_NAME}"
    # Add update logic here
    success "Package updated: ${PACKAGE_NAME}"
}

# Remove a package
remove_package() {
    # Implementation for package removal
    info "Removing package: ${PACKAGE_NAME}"
    # Add removal logic here
    success "Package removed: ${PACKAGE_NAME}"
}

# List available packages
list_packages() {
    info "Available packages in ${PKG_DIR}:"
    if [ -d "${PKG_DIR}" ]; then
        (cd "${PKG_DIR}" && ls -1)
    else
        warn "Package directory not found: ${PKG_DIR}"
    fi
}

# Clean build directory
clean_build() {
    info "Cleaning build directory: ${BUILD_DIR}"
    if [ -d "${BUILD_DIR}" ]; then
        rm -rf "${BUILD_DIR}"/*
        success "Build directory cleaned"
    else
        warn "Build directory not found: ${BUILD_DIR}"
    fi
}

# Main function
main() {
    parse_args "$@"
    
    case "${ACTION}" in
        build) build_package ;;
        install) install_package ;;
        update) update_package ;;
        remove) remove_package ;;
        list) list_packages ;;
        clean) clean_build ;;
    esac
}

# Run the script
main "$@"
