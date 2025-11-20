#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="${SCRIPT_DIR}/hooks"

echo "[+] Fixing hook file extensions..."

# Create hooks directory if it doesn't exist
mkdir -p "${HOOKS_DIR}"

# Rename .hook files to .hook.chroot
for file in "${HOOKS_DIR}"/*.hook; do
    if [ -f "$file" ]; then
        new_name="${file%.hook}.hook.chroot"
        echo "  - Renaming $(basename "$file") to $(basename "$new_name")"
        mv -- "$file" "$new_name"
    fi
done

echo "[+] Hook file extensions fixed."
