#!/bin/bash

# Cleanup script for Packer
set -e

echo "Starting system cleanup..."

# Clean package cache
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

# Clean up temporary files
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -f /var/cache/apt/archives/*.deb
rm -f /var/cache/apt/*.bin
rm -f /var/lib/apt/lists/*

# Clean up logs
find /var/log -type f -name "*.gz" -delete
find /var/log -type f -name "*.log" -exec truncate -s 0 {} \;

# Clean up bash history
rm -f /root/.bash_history
rm -f /home/vagrant/.bash_history

# Clean up SSH host keys
rm -f /etc/ssh/ssh_host_*

# Clean up machine ID
rm -f /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clean up cloud-init if present
if [ -f /var/log/cloud-init.log ]; then
    cloud-init clean
    rm -f /var/log/cloud-init*.log
fi

# Zero out disk to reduce box size
dd if=/dev/zero of=/EMPTY bs=1M 2>/dev/null || true
rm -f /EMPTY
sync

echo "System cleanup complete!"
