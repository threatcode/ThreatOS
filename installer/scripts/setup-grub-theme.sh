#!/bin/bash

# ThreatOS GRUB Theme Setup Script
# This script installs and configures the GRUB theme for ThreatOS
# Supports both BIOS and UEFI systems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
THEME_NAME="threatos"
VERSION="1.0"

# Detect system type
if [ -d "/boot/efi/EFI" ]; then
    echo -e "${GREEN}[+]${NC} Detected UEFI system"
    GRUB_THEME_DIR="/boot/efi/EFI/grub/themes/${THEME_NAME}"
    GRUB_CFG="/etc/default/grub"
    GRUB_MKCONFIG="grub-mkconfig -o /boot/efi/EFI/grub/grub.cfg"
else
    echo -e "${GREEN}[+]${NC} Detected BIOS system"
    GRUB_THEME_DIR="/boot/grub/themes/${THEME_NAME}"
    GRUB_CFG="/etc/default/grub"
    GRUB_MKCONFIG="grub-mkconfig -o /boot/grub/grub.cfg"
fi

GRUB_CFG_D="${GRUB_CFG}.d"
THEME_CONFIG="${GRUB_CFG_D}/99_${THEME_NAME}_theme"
BACKUP_DIR="/tmp/threatos_grub_backup_$(date +%s)"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}[!]${NC} This script requires root privileges. Please run with sudo."
    exit 1
fi

# Function to check command status
check_status() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+]${NC} $1"
    else
        echo -e "${RED}[!]${NC} Error: $2"
        echo -e "${YELLOW}[*]${NC} Check the logs at /var/log/threatos-grub-theme.log"
        exit 1
    fi
}

# Create backup of current configuration
echo -e "\n${GREEN}[+]${NC} Creating backup of current GRUB configuration..."
mkdir -p "${BACKUP_DIR}"
cp -a "${GRUB_CFG}" "${BACKUP_DIR}/" 2>/dev/null || true
cp -a "${GRUB_CFG_D}" "${BACKUP_DIR}/" 2>/dev/null || true
echo "Backup created at: ${BACKUP_DIR}"

# Install required dependencies
echo -e "\n${GREEN}[+]${NC} Checking for required dependencies..."
if ! command -v grub-mkconfig &> /dev/null; then
    echo -e "${YELLOW}[*]${NC} GRUB tools not found. Installing..."
    apt-get update && apt-get install -y grub2-common grub-pc
    check_status "GRUB tools installed" "Failed to install GRUB tools"
fi

# Check for required fonts
if ! dpkg -l fonts-dejavu-core >/dev/null 2>&1; then
    echo -e "${YELLOW}[*]${NC} Installing required fonts..."
    apt-get update && apt-get install -y fonts-dejavu-core
    check_status "Fonts installed" "Failed to install required fonts"
fi

# Create theme directory
echo -e "\n${GREEN}[+]${NC} Creating theme directory..."
mkdir -p "${GRUB_THEME_DIR}"
check_status "Theme directory created" "Failed to create theme directory"

# Copy theme files
echo -e "\n${GREEN}[+]${NC} Copying theme files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -r "${SCRIPT_DIR}/../common/bootloaders/grub-pc/"* "${GRUB_THEME_DIR}/"
check_status "Theme files copied" "Failed to copy theme files"

# Create background image if it doesn't exist
if [ ! -f "${GRUB_THEME_DIR}/background.png" ]; then
    echo -e "\n${YELLOW}[*]${NC} Creating default background image..."
    if command -v convert &> /dev/null; then
        convert -size 1920x1080 xc:black -fill '#00ff00' -pointsize 72 -gravity center \
            -draw "text 0,0 'THREATOS'" "${GRUB_THEME_DIR}/background.png"
        check_status "Default background created" "Failed to create background image"
    else
        echo -e "${YELLOW}[!]${NC} ImageMagick not found. Using default background."
        # Create a simple text file as fallback
        echo "THREATOS BOOT MENU" > "${GRUB_THEME_DIR}/background.png"
    fi
fi

# Create GRUB configuration directory if it doesn't exist
echo -e "\n${GREEN}[+]${NC} Configuring GRUB..."
mkdir -p "${GRUB_CFG_D}"
check_status "GRUB config directory created" "Failed to create GRUB config directory"

# Add theme configuration
cat > "${THEME_CONFIG}" << EOL
# ThreatOS GRUB Theme Configuration
GRUB_THEME="${GRUB_THEME_DIR}/grub-theme.in"
GRUB_GFXMODE="auto"
GRUB_GFXPAYLOAD_LINUX="keep"
GRUB_BACKGROUND="${GRUB_THEME_DIR}/background.png"
GRUB_TERMINAL_OUTPUT="gfxterm"
GRUB_GFXMODE="1920x1080x32,auto"
GRUB_GFXPAYLOAD_LINUX="keep"
EOL
check_status "GRUB theme configuration created" "Failed to create GRUB theme configuration"

# Update GRUB configuration
echo -e "\n${GREEN}[+]${NC} Updating GRUB configuration..."
${GRUB_MKCONFIG} > /dev/null 2>&1
check_status "GRUB configuration updated" "Failed to update GRUB configuration"

# Set correct permissions
echo -e "\n${GREEN}[+]${NC} Setting permissions..."
chmod -R 755 "${GRUB_THEME_DIR}"
chmod 644 "${THEME_CONFIG}"

# Create desktop entry for easy reconfiguration
DESKTOP_ENTRY="/usr/share/applications/threatos-grub-theme.desktop"
cat > "${DESKTOP_ENTRY}" << EOL
[Desktop Entry]
Name=ThreatOS GRUB Theme
Comment=Configure ThreatOS GRUB Theme
Exec=sudo ${SCRIPT_DIR}/setup-grub-theme.sh
Icon=grub-customizer
Terminal=true
Type=Application
Categories=System;Settings;
EOL
chmod +x "${DESKTOP_ENTRY}"

# Final output
echo -e "\n${GREEN}================================================${NC}"
echo -e "${GREEN}[+]${NC} GRUB theme installation complete!"
echo -e "${GREEN}================================================${NC}"
echo -e "Theme location: ${GRUB_THEME_DIR}"
echo -e "Configuration: ${THEME_CONFIG}"
echo -e "Backup location: ${BACKUP_DIR}"
echo -e "${YELLOW}[*]${NC} To apply changes, please reboot your system."
echo -e "${YELLOW}[*]${NC} To revert changes, restore from backup in ${BACKUP_DIR}"
echo -e "\n${GREEN}ThreatOS GRUB Theme v${VERSION} - Installation Complete!${NC}\n"
