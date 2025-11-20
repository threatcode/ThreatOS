#!/bin/bash

# ThreatOS Installer Build Script
# This script builds the ThreatOS installer ISO

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
INSTALLER_DIR="${SCRIPT_DIR}/installer"
OUTPUT_DIR="${SCRIPT_DIR}/installer-artifacts"
BUILD_ARCH="amd64"
BUILD_DISTRO="bookworm"
BUILD_MIRROR="http://deb.debian.org/debian"
BUILD_SECURITY_MIRROR="http://security.debian.org"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] This script requires root privileges. Please run with sudo."
    exit 1
fi

# Create output directory
mkdir -p "${OUTPUT_DIR}"

# Install required dependencies
echo -e "\n[+] Installing required dependencies..."
apt-get update
apt-get install -y \
    live-build \
    squashfs-tools \
    genisoimage \
    syslinux-utils \
    isolinux \
    syslinux \
    syslinux-efi \
    grub-common \
    grub2-common \
    mtools \
    xorriso \
    wget \
    git \
    ca-certificates

# Initialize live-build configuration
echo -e "\n[+] Initializing live-build configuration..."
lb clean --purge
lb config \
    --architectures "${BUILD_ARCH}" \
    --distribution "${BUILD_DISTRO}" \
    --archive-areas "main contrib non-free" \
    --mirror-bootstrap "${BUILD_MIRROR}" \
    --mirror-chroot "${BUILD_MIRROR}" \
    --mirror-chroot-security "${BUILD_SECURITY_MIRROR}" \
    --security true \
    --updates true \
    --backports true \
    --firmware-binary true \
    --firmware-chroot true \
    --linux-packages "linux-image-amd64" \
    --bootappend-live "boot=live components splash quiet" \
    --debian-installer live \
    --iso-application "ThreatOS Installer" \
    --iso-publisher "ThreatOS Team" \
    --iso-volume "ThreatOS Installer"

# Copy installer files
echo -e "\n[+] Copying installer files..."
cp -r "${INSTALLER_DIR}/config/"* "config/" || true
cp -r "${INSTALLER_DIR}/hooks/"* "config/hooks/" || true

# Build the installer
echo -e "\n[+] Building ThreatOS Installer..."
lb build

# Move the built ISO to the output directory
if [ -f "live-image-${BUILD_ARCH}.hybrid.iso" ]; then
    mv "live-image-${BUILD_ARCH}.hybrid.iso" "${OUTPUT_DIR}/threatos-installer-$(date +%Y%m%d).iso"
    echo -e "\n[+] Installer built successfully: ${OUTPUT_DIR}/threatos-installer-$(date +%Y%m%d).iso"
else
    echo -e "\n[!] Error: Failed to build the installer ISO"
    exit 1
fi
