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

# Function to print test header
print_header() {
    echo -e "\n${YELLOW}=== $1 ===${NC}"
}

# Function to run a test
run_test() {
    local test_name="$1"
    local test_cmd="$2"
    
    echo -n "Testing ${test_name}... "
    if eval "$test_cmd" &>/dev/null; then
        echo -e "${GREEN}PASS${NC}"
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        return 1
    fi
}

# Function to check if container is running
is_container_running() {
    local container_name="$1"
    docker ps --filter "name=^${container_name}$" --format '{{.Names}}' | grep -q "^${container_name}$"
}

# Function to check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Test 1: Install application
print_header "Test 1: Install Application"
run_test "Install test application" "sudo /usr/local/bin/threatos-appmgr install ${TEST_APP} ${TEST_COMPOSE_FILE}" || exit 1

# Test 2: Verify installation
print_header "Test 2: Verify Installation"
run_test "Check if application directory exists" "dir_exists '/etc/threatos/apps/${TEST_APP}'" || exit 1
run_test "Check if compose file exists" "[ -f '/etc/threatos/apps/${TEST_APP}/docker-compose.yml' ]" || exit 1
run_test "Check if container is running" "is_container_running '${TEST_APP}-web-1'" || exit 1

# Test 3: Test web server
print_header "Test 3: Test Web Server"
run_test "Check if web server is accessible" "curl -s http://localhost:8080 | grep -q 'Welcome to nginx'" || exit 1

# Test 4: Stop application
print_header "Test 4: Stop Application"
run_test "Stop application" "sudo /usr/local/bin/threatos-appmgr stop ${TEST_APP}" || exit 1
run_test "Verify container is stopped" "! is_container_running '${TEST_APP}-web-1'" || exit 1

# Test 5: Start application
print_header "Test 5: Start Application"
run_test "Start application" "sudo /usr/local/bin/threatos-appmgr start ${TEST_APP}" || exit 1
run_test "Verify container is running" "is_container_running '${TEST_APP}-web-1'" || exit 1

# Test 6: Uninstall application
print_header "Test 6: Uninstall Application"
run_test "Uninstall application" "echo 'y' | sudo /usr/local/bin/threatos-appmgr uninstall ${TEST_APP}" || exit 1

# Test 7: Verify cleanup
print_header "Test 7: Verify Cleanup"
run_test "Verify container is removed" "! is_container_running '${TEST_APP}-web-1'" || exit 1
run_test "Verify application directory is removed" "! dir_exists '/etc/threatos/apps/${TEST_APP}'" || exit 1

echo -e "\n${GREEN}All tests passed successfully!${NC}"
