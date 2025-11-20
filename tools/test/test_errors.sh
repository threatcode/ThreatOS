#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
TEST_APP="test-nginx"
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_APP_DIR="${TEST_DIR}/test-app"
TEST_COMPOSE_FILE="${TEST_APP_DIR}/docker-compose.yml"
INVALID_COMPOSE_FILE="${TEST_DIR}/invalid-compose.yml"

# Create an invalid compose file for testing
cat > "${INVALID_COMPOSE_FILE}" << 'EOF'
version: '3.8'
services:
  web:
    image: non-existent-image:latest
    ports:
      - "8080:80"
EOF

# Function to print test header
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to expect a command to fail
expect_failure() {
    local test_name="$1"
    local test_cmd="$2"
    local expected_error="$3"
    
    echo -n "Testing ${test_name}... "
    if output=$(eval "$test_cmd" 2>&1); then
        echo -e "${RED}FAIL (expected failure but command succeeded)${NC}"
        return 1
    elif ! echo "$output" | grep -q "$expected_error"; then
        echo -e "${RED}FAIL (unexpected error message)${NC}"
        echo "Expected: $expected_error"
        echo "Got: $output"
        return 1
    else
        echo -e "${GREEN}PASS${NC}"
        return 0
    fi
}

# Test 1: Install with invalid app name
print_header "Test 1: Invalid Application Name"
expect_failure \
    "Install with invalid app name" \
    "sudo /usr/local/bin/threatos-appmgr install 'invalid name!' ${TEST_COMPOSE_FILE}" \
    "Invalid application name"

# Test 2: Install non-existent compose file
print_header "Test 2: Non-existent Compose File"
expect_failure \
    "Install with non-existent compose file" \
    "sudo /usr/local/bin/threatos-appmgr install ${TEST_APP} /non/existent/file.yml" \
    "Compose file not found"

# Test 3: Install with invalid compose file
print_header "Test 3: Invalid Compose File"
expect_failure \
    "Install with invalid compose file" \
    "sudo /usr/local/bin/threatos-appmgr install ${TEST_APP} ${INVALID_COMPOSE_FILE}" \
    "Invalid Docker Compose file"

# Install the test app for further testing
print_header "Setting up for further tests..."
sudo /usr/local/bin/threatos-appmgr install ${TEST_APP} ${TEST_COMPOSE_FILE} >/dev/null 2>&1 || true

# Test 4: Install already installed app
print_header "Test 4: Install Already Installed App"
expect_failure \
    "Install already installed app" \
    "sudo /usr/local/bin/threatos-appmgr install ${TEST_APP} ${TEST_COMPOSE_FILE}" \
    "already exists"

# Test 5: Stop non-existent app
print_header "Test 5: Stop Non-existent App"
expect_failure \
    "Stop non-existent app" \
    "sudo /usr/local/bin/threatos-appmgr stop non-existent-app" \
    "not found"

# Test 6: Uninstall without confirmation
print_header "Test 6: Uninstall Without Confirmation"
# This should fail because it expects user confirmation
expect_failure \
    "Uninstall without confirmation" \
    "echo 'n' | sudo /usr/local/bin/threatos-appmgr uninstall ${TEST_APP}" \
    "Aborted"

# Cleanup
print_header "Cleaning up..."
echo 'y' | sudo /usr/local/bin/threatos-appmgr uninstall ${TEST_APP} >/dev/null 2>&1 || true
rm -f "${INVALID_COMPOSE_FILE}"

echo -e "\n${GREEN}All error condition tests completed!${NC}"
