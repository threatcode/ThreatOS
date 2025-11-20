#!/bin/bash

# Add common Debian/Ubuntu mirrors to Mirrorbits

# Check if running in Docker
if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    # Inside container
    MIRRORBITS_CMD="mirrorbits -conf /etc/mirrorbits.conf"
else
    # Using Docker Compose
    MIRRORBITS_CMD="docker-compose -f ../docker-compose.mirrorbits.yml exec -T mirrorbits mirrorbits -conf /etc/mirrorbits.conf"
fi

# Function to add a mirror
add_mirror() {
    local name=$1
    local http_url=$2
    local rsync_url=$3
    
    echo "Adding mirror: $name"
    $MIRRORBITS_CMD add --name "$name" --http "$http_url" --rsync "$rsync_url"
}

# Main mirrors
echo "Adding main mirrors..."

# Debian mirrors
add_mirror "Debian Main" \
    "http://deb.debian.org/debian" \
    "rsync://deb.debian.org/debian"

add_mirror "Debian Security" \
    "http://security.debian.org" \
    "rsync://security.debian.org/security"

# Ubuntu mirrors (commented out by default)
# add_mirror "Ubuntu Main" \
#     "http://archive.ubuntu.com/ubuntu" \
#     "rsync://archive.ubuntu.com/ubuntu"
# 
# add_mirror "Ubuntu Security" \
#     "http://security.ubuntu.com/ubuntu" \
#     "rsync://security.ubuntu.com/ubuntu"

# Enable all added mirrors
echo "Enabling all mirrors..."
$MIRRORBITS_CMD enable --all

# Update mirror information
echo "Updating mirror information..."
$MIRRORBITS_CMD update

echo "Mirror setup complete!"
