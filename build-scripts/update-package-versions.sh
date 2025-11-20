#!/bin/bash
set -e

# Create a temporary directory
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Get current package versions
echo "Updating package versions..."
apt-get update
apt-cache policy $(dpkg-query -f '${Package}\n' -W) > "$TMPDIR/versions.txt"

# Function to update a package list file
update_package_list() {
    local input_file="$1"
    local output_file="$1.updated"
    
    # Process each line in the input file
    while IFS= read -r line || [ -n "$line" ]; do
        # Skip comments and empty lines
        if [[ -z "$line" || "$line" == \#* ]]; then
            echo "$line" >> "$output_file"
            continue
        fi
        
        # Get package name (strip any version constraints)
        local pkg_name="${line%%=*}"
        pkg_name="${pkg_name%% *}"
        
        # Get current version
        local version=$(grep -A1 "^${pkg_name}:" "$TMPDIR/versions.txt" | grep -oP 'Candidate: \K.*' | head -1)
        
        if [ -n "$version" ]; then
            # If line already has a version, update it, otherwise append the version
            if [[ "$line" == *"="* ]]; then
                echo "${line%%=*}=${version}" >> "$output_file"
            else
                echo "${line}=${version}" >> "$output_file"
            fi
        else
            # If we can't find a version, keep the line as is
            echo "$line" >> "$output_file"
        fi
    done < "$input_file"
    
    # Replace the original file
    mv "$output_file" "$input_file"
    echo "Updated: $input_file"
}

# Update all package list files
for pkg_list in /Users/neopilot/ThreatOS/build-scripts/package-lists/*.list.chroot; do
    if [ -f "$pkg_list" ]; then
        update_package_list "$pkg_list"
    fi
done

echo "Package versions have been updated in all .list.chroot files"
