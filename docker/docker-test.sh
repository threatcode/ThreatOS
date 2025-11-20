#!/bin/bash
set -e

# Configuration
CONTAINER_NAME="threatos-test"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Stop and remove any existing container
echo "[+] Cleaning up any existing test container..."
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

# Run the test container
echo "[+] Starting test container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --privileged \
    -v "$PWD:/threatos" \
    -w /threatos \
    threatos/builder \
    sleep infinity

# Test the build environment
echo -e "\n[+] Testing build environment..."
docker exec "$CONTAINER_NAME" /bin/bash -c "
    set -e
    echo 'Testing build tools...'
    lb --version
    dpkg-query -W live-build
    
    echo -e '\nTesting architecture...'
    uname -m
    
    echo -e '\nTesting build script...'
    ./build-threatos.sh --help
"

echo -e "\n[+] Tests completed successfully!"

# Clean up
echo -e "\n[+] Cleaning up..."
docker rm -f "$CONTAINER_NAME"

echo -e "\n[+] All tests passed! The build environment is ready to use."
