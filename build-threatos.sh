#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPTS_DIR="${SCRIPT_DIR}/build-scripts"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] This script requires root privileges. Please run with sudo."
    exit 1
fi

# Parse command line arguments
BUILD_DESKTOP=false
DESKTOP_VARIANT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --desktop)
            BUILD_DESKTOP=true
            if [[ -n "$2" && ! "$2" == --* ]]; then
                DESKTOP_VARIANT="$2"
                shift
            fi
            shift
            ;;
        --list-variants)
            echo "Available desktop variants:"
            "${BUILD_SCRIPTS_DIR}/select-desktop-variant.sh" --list
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--desktop [variant] | --list-variants]"
            exit 1
            ;;
    esac
done

# Check dependencies
echo -e "\n[+] Checking build dependencies..."
if ! "${BUILD_SCRIPTS_DIR}/check-dependencies.sh"; then
    echo "[!] Please install the missing dependencies and try again."
    exit 1
fi

# Fix hook extensions
echo -e "\n[+] Preparing build environment..."
"${BUILD_SCRIPTS_DIR}/fix-hook-extensions.sh"

# Set output directory and build command
if [ "${BUILD_DESKTOP}" = true ]; then
    OUTPUT_DIR="${SCRIPT_DIR}/desktop-artifacts"
    BUILD_CMD="${BUILD_SCRIPTS_DIR}/build.sh desktop"
    
    # Export the selected variant if specified
    if [ -n "${DESKTOP_VARIANT}" ]; then
        export SELECTED_VARIANT="${DESKTOP_VARIANT}"
    fi
    
    # Source the desktop config to set up the environment
    source "${BUILD_SCRIPTS_DIR}/build-config-desktop"
else
    OUTPUT_DIR="${SCRIPT_DIR}/iso-artifacts"
    BUILD_CMD="${BUILD_SCRIPTS_DIR}/build.sh"
fi

# Ensure output directory exists
mkdir -p "${OUTPUT_DIR}"

# Run the build
echo -e "\n[+] Starting ThreatOS build process..."
cd "${BUILD_SCRIPTS_DIR}" && eval "$BUILD_CMD"

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\n[+] Build completed successfully!"
    
    if [ "${BUILD_DESKTOP}" = true ]; then
        echo "[+] Disk image is available in the 'desktop-artifacts' directory."
        echo -e "\nTo create a bootable USB drive, you can use the following command:"
        echo "    sudo dd if=desktop-artifacts/threatos-desktop-*.img of=/dev/sdX bs=4M status=progress && sync"
    else
        echo "[+] ISO file is available in the 'iso-artifacts' directory."
        echo -e "\nTo create a bootable USB drive, you can use the following command:"
        echo "    sudo dd if=iso-artifacts/threatos-*.iso of=/dev/sdX bs=4M status=progress && sync"
    fi
    
    echo -e "\nReplace '/dev/sdX' with your actual USB device (e.g., /dev/sdb)."
    echo "WARNING: This will erase all data on the target device!"
else
    echo -e "\n[!] Build failed. Check the build log for details:"
    if [ "${BUILD_DESKTOP}" = true ]; then
        echo "    ${SCRIPT_DIR}/desktop-artifacts/build.log"
    else
        echo "    ${SCRIPT_DIR}/iso-artifacts/build.log"
    fi
    exit 1
fi
