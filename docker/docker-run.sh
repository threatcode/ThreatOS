#!/bin/bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Check if container is already running
if docker ps --format '{{.Names}}' | grep -q "^threatos-builder$"; then
    echo "[+] ThreatOS builder container is already running. Attaching..."
    docker exec -it threatos-builder /bin/bash
    exit 0
fi

# Start the container if not already running
echo "[+] Starting ThreatOS builder container..."
docker-compose -f docker/docker-compose.yml up -d

# Attach to the container
echo -e "\n[+] Attaching to the container..."
echo -e "\nWelcome to the ThreatOS build environment!"
echo -e "To build ThreatOS, run:\n  ./build-threatos.sh\n"

docker exec -it threatos-builder /bin/bash
