#!/bin/bash
set -e

# Create a temporary directory
TMPDIR=$(mktemp -d -p /tmp)
echo "[+] Created temporary directory: ${TMPDIR}"

# Copy the project to the temporary directory
echo "[+] Copying project to temporary directory..."
cp -a /workspaces/ThreatOS "${TMPDIR}/ThreatOS"
echo "[+] Project copied."

# Change to the temporary directory and run the build
echo "[+] Changing to temporary directory and starting build..."
cd "${TMPDIR}/ThreatOS"
sudo bash build-threatos.sh

# Copy the artifacts back to the original project directory
echo "[+] Copying artifacts back to original project directory..."
mkdir -p /workspaces/ThreatOS/iso-artifacts
cp -a iso-artifacts/* /workspaces/ThreatOS/iso-artifacts/
echo "[+] Artifacts copied."

# Clean up the temporary directory
echo "[+] Cleaning up temporary directory..."
rm -rf "${TMPDIR}"
echo "[+] Cleanup complete."
