#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPTS_DIR="${SCRIPT_DIR}/build-scripts"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] This script requires root privileges. Please run with sudo."
    exit 1
fi

# Check dependencies
echo -e "\n[+] Checking build dependencies..."
if ! "${BUILD_SCRIPTS_DIR}/check-dependencies.sh"; then
    echo "[!] Please install the missing dependencies and try again."
    exit 1
fi

# Fix hook extensions
echo -e "\n[+] Preparing build environment..."
"${BUILD_SCRIPTS_DIR}/fix-hook-extensions.sh"

# Ensure output directory exists
mkdir -p "${SCRIPT_DIR}/desktop-artifacts"

# Export desktop build flag
export BUILD_DESKTOP_IMAGE=true

# Run the build
echo -e "\n[+] Starting ThreatOS Desktop build process..."
cd "${BUILD_SCRIPTS_DIR}" && ./build.sh desktop

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\n[+] Desktop build completed successfully!"
    echo "[+] Image files are available in the 'desktop-artifacts' directory."
    echo -e "\nTo create a bootable USB drive, you can use the following command:"
    echo "    sudo dd if=desktop-artifacts/threatos-desktop-*.img of=/dev/sdX bs=4M status=progress && sync"
    echo -e "\nReplace '/dev/sdX' with your actual USB device (e.g., /dev/sdb)."
    echo "WARNING: This will erase all data on the target device!"
else
    echo -e "\n[!] Desktop build failed. Check the build log for details:"
    echo "    ${SCRIPT_DIR}/desktop-artifacts/build.log"
    exit 1
fi
