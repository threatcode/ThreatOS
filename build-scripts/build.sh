#!/bin/bash

# ThreatOS Build Script
# This script builds the ThreatOS live image

set -e

# Load build configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/build-config"

# Check if building desktop image
BUILD_DESKTOP=${1:-false}

# Set build type and output directory
if [ "${BUILD_DESKTOP}" = "desktop" ]; then
    echo "[+] Building Desktop Edition"
    BUILD_OPTIONS+=(--binary-images "img")
    BUILD_OPTIONS+=(--debian-installer "live")
    BUILD_OPTIONS+=(--system "live")
    OUTPUT_DIR="${SCRIPT_DIR}/../desktop-artifacts"
    OUTPUT_FILENAME="threatos-desktop-${BUILD_DISTRIBUTION}-${BUILD_ARCH}-$(date +%Y%m%d)"
else
    echo "[+] Building Standard Edition"
    OUTPUT_DIR="${SCRIPT_DIR}/../iso-artifacts"
fi

# Create output directory if it doesn't exist
mkdir -p "${OUTPUT_DIR}"

# Initialize live-build configuration
echo "[+] Initializing live-build configuration..."
lb clean --purge

# Apply build configuration
echo "[+] Configuring build with options: ${BUILD_OPTIONS[*]}"
lb config "${BUILD_OPTIONS[@]}"

# Copy package lists
for pkg_list in ${PACKAGE_LISTS}; do
    if [ -f "config/${pkg_list}" ]; then
        mkdir -p "config/package-lists/$(dirname "${pkg_list}")"
        cp "config/${pkg_list}" "config/package-lists/${pkg_list}"
    fi
    
    # Also check in the build-scripts/package-lists directory
    if [ -f "${SCRIPT_DIR}/package-lists/$(basename "${pkg_list}")" ]; then
        mkdir -p "config/package-lists/$(dirname "${pkg_list}")"
        cp "${SCRIPT_DIR}/package-lists/$(basename "${pkg_list}")" "config/package-lists/${pkg_list}"
    fi
done

# Copy hooks
for hook in ${BUILD_HOOKS}; do
    if [ -f "config/${hook}" ]; then
        mkdir -p "config/hooks/$(dirname "${hook}")"
        cp "config/${hook}" "config/hooks/$(basename "${hook}")"
        chmod +x "config/hooks/$(basename "${hook}")"
    fi
    
    # Also check in the build-scripts/hooks directory
    if [ -f "${SCRIPT_DIR}/hooks/$(basename "${hook}")" ]; then
        mkdir -p "config/hooks/$(dirname "${hook}")"
        cp "${SCRIPT_DIR}/hooks/$(basename "${hook}")" "config/hooks/$(basename "${hook}")"
        chmod +x "config/hooks/$(basename "${hook}")"
    fi
done

# Build the image
echo "[+] Starting build process..."
lb build 2>&1 | tee "${OUTPUT_DIR}/build.log"

# Check if build was successful and handle output files
if [ "${BUILD_DESKTOP}" = "desktop" ]; then
    # Handle desktop image output
    if [ -f "live-image-${BUILD_ARCH}.img" ]; then
        # Rename and move the output file
        mv "live-image-${BUILD_ARCH}.img" "${OUTPUT_DIR}/${OUTPUT_FILENAME}.img"
        
        # Calculate checksums
        cd "${OUTPUT_DIR}"
        sha256sum "${OUTPUT_FILENAME}.img" > "${OUTPUT_FILENAME}.img.sha256"
        
        # Create compressed version
        echo "[+] Creating compressed image..."
        xz -9 --threads=0 "${OUTPUT_FILENAME}.img"
        sha256sum "${OUTPUT_FILENAME}.img.xz" > "${OUTPUT_FILENAME}.img.xz.sha256"
        
        echo -e "\n[+] Desktop build completed successfully!"
        echo "[+] Image: ${OUTPUT_DIR}/${OUTPUT_FILENAME}.img.xz"
        echo "[+] Checksum: ${OUTPUT_DIR}/${OUTPUT_FILENAME}.img.xz.sha256"
    else
        echo -e "\n[!] Desktop build failed. Check the build log for details:"
        echo "    ${OUTPUT_DIR}/build.log"
        exit 1
    fi
else
    # Handle standard ISO output
    if [ -f "live-image-${BUILD_ARCH}.hybrid.iso" ]; then
        # Rename and move the output file
        mv "live-image-${BUILD_ARCH}.hybrid.iso" "${OUTPUT_DIR}/${OUTPUT_FILENAME}.iso"
        
        # Calculate checksums
        cd "${OUTPUT_DIR}"
        sha256sum "${OUTPUT_FILENAME}.iso" > "${OUTPUT_FILENAME}.iso.sha256"
        
        echo -e "\n[+] Build completed successfully!"
        echo "[+] ISO: ${OUTPUT_DIR}/${OUTPUT_FILENAME}.iso"
        echo "[+] Checksum: ${OUTPUT_DIR}/${OUTPUT_FILENAME}.iso.sha256"
    else
        echo -e "\n[!] Build failed. Check the build log for details:"
        echo "    ${OUTPUT_DIR}/build.log"
        exit 1
    fi
fi
