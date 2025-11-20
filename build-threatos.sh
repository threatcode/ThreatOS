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
mkdir -p "${SCRIPT_DIR}/iso-artifacts"

# Run the build
echo -e "\n[+] Starting ThreatOS build process..."
cd "${BUILD_SCRIPTS_DIR}" && ./build.sh

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "\n[+] Build completed successfully!"
    echo "[+] ISO file is available in the 'iso-artifacts' directory."
    echo -e "\nTo create a bootable USB drive, you can use the following command:"
    echo "    sudo dd if=iso-artifacts/threatos-*.iso of=/dev/sdX bs=4M status=progress && sync"
    echo -e "\nReplace '/dev/sdX' with your actual USB device (e.g., /dev/sdb)."
    echo "WARNING: This will erase all data on the target device!"
else
    echo -e "\n[!] Build failed. Check the build log for details:"
    echo "    ${SCRIPT_DIR}/iso-artifacts/build.log"
    exit 1
fi
