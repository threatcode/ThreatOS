#!/bin/bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Build the Docker image
echo "[+] Building ThreatOS builder image..."
docker-compose -f docker/docker-compose.yml build --no-cache

echo -e "\n[+] Build complete! You can now use the following commands:"
echo "  - Start the build environment: docker/docker-run.sh"
echo "  - Build ThreatOS inside the container: ./build-threatos.sh"
