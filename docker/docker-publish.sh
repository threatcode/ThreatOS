#!/bin/bash
set -e

# Configuration
IMAGE_NAME="threatos/builder"
VERSION="latest"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# Ensure we're logged in to Docker Hub
echo "[+] Checking Docker login status..."
if ! docker system info &>/dev/null; then
    echo "[!] Docker daemon not running or not accessible"
    exit 1
fi

# Build the image if not already built
if ! docker images | grep -q "${IMAGE_NAME}"; then
    echo "[+] Building Docker image..."
    ./docker/docker-build.sh
fi

# Tag the image
echo "[+] Tagging Docker image..."
docker tag "${IMAGE_NAME}:latest" "${IMAGE_NAME}:${VERSION}"

# Push to Docker Hub
echo "[+] Pushing to Docker Hub..."
docker push "${IMAGE_NAME}:${VERSION}"

echo -e "\n[+] Successfully published ${IMAGE_NAME}:${VERSION}"
