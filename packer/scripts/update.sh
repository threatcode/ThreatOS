#!/bin/bash

# Update system and install required packages
set -e

echo "Updating package lists..."
apt-get update

echo "Upgrading installed packages..."
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install build essentials and common tools
echo "Installing build tools and dependencies..."
DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    build-essential \
    linux-headers-$(uname -r) \
    dkms \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release

echo "System update and package installation complete."
