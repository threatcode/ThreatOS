#!/bin/bash
# Installation script for ThreatOS Application Manager

set -e

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p /etc/threatos/apps
mkdir -p /var/lib/threatos/apps
mkdir -p /var/log/threatos/apps
mkdir -p /usr/local/bin

# Set permissions
echo "Setting permissions..."
chmod 755 /etc/threatos
chmod 750 /etc/threatos/apps
chmod 750 /var/lib/threatos/apps
chmod 750 /var/log/threatos/apps

# Install the application manager
echo "Installing application manager..."
cp threatos-appmgr /usr/local/bin/
chmod 755 /usr/local/bin/threatos-appmgr

# Create systemd service for auto-starting applications
echo "Creating systemd service..."
cat > /etc/systemd/system/threatos-appmgr.service << 'EOL'
[Unit]
Description=ThreatOS Application Manager
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/etc/threatos/apps
ExecStart=/bin/true

# Auto-start all applications
ExecStartPost=/bin/sh -c 'for app in /etc/threatos/apps/*; do [ -d "$app" ] && /usr/local/bin/threatos-$(basename "$app") up -d; done'

# Stop all applications on shutdown
ExecStop=/bin/sh -c 'for app in /etc/threatos/apps/*; do [ -d "$app" ] && /usr/local/bin/threatos-$(basename "$app") down; done'

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable the service
echo "Enabling services..."
systemctl daemon-reload
systemctl enable threatos-appmgr.service

# Initialize the application manager
echo "Initializing ThreatOS Application Manager..."
threatos-appmgr init

echo "\nThreatOS Application Manager has been installed successfully!"
echo "To get started, try installing a sample application:"
echo "  sudo threatos-appmgr install myapp /path/to/docker-compose.yml"
echo "  sudo threatos-myapp up -d"

echo "\nFor more information, see the README.md file."
