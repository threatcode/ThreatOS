#!/bin/bash

set -e

echo "[+] Checking for required dependencies..."

# List of required packages
REQUIRED_PACKAGES=(
    "live-build"
    "squashfs-tools"
    "genisoimage"
    "syslinux-utils"
    "isolinux"
    "syslinux"
    "syslinux-efi"
    "grub-pc"
    "grub-efi-amd64"
    "grub-efi-ia32"
    "grub-common"
    "grub2-common"
    "mtools"
    "xorriso"
    "wget"
)

# Check each package
MISSING_PKGS=()
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        MISSING_PKGS+=("$pkg")
    fi
done

# Print results
if [ ${#MISSING_PKGS[@]} -eq 0 ]; then
    echo "[+] All required packages are installed."
else
    echo "[!] Missing packages:"
    for pkg in "${MISSING_PKGS[@]}"; do
        echo "    - $pkg"
    done
    echo -e "\nInstall them using:"
    echo "    sudo apt-get update && sudo apt-get install -y ${MISSING_PKGS[*]}"
    exit 1
fi

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] Some operations may require root privileges. Consider running with sudo."
fi

echo "[+] System check complete. You're ready to build ThreatOS!"
