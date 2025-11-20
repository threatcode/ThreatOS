#!/bin/bash

# Test Mirrorbits Setup

# Configuration
MIRRORBITS_URL="http://localhost:8080"
TEST_FILES=(
    "dists/bookworm/InRelease"
    "dists/bookworm/main/binary-amd64/Packages.gz"
    "pool/main/"
)

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed."
    exit 1
fi

# Function to test a file
# Function to test a file
test_file() {
    local file=$1
    echo -e "\nTesting: $file"
    echo "----------------------------------------"
    
    # Get the mirror list
    echo "Getting mirror list for: $file"
    response=$(curl -s "$MIRRORBITS_URL/mirrorlist/$file")
    
    if [ -z "$response" ]; then
        echo "  ❌ Error: Empty response from Mirrorbits"
        return 1
    fi
    
    # Check if we got a valid mirror list
    if [[ "$response" == *"No mirror found"* ]]; then
        echo "  ❌ Error: No mirrors found for $file"
        return 1
    fi
    
    # Count mirrors
    mirror_count=$(echo "$response" | wc -l)
    echo "  ✅ Found $mirror_count mirrors"
    
    # Test the first mirror
    first_mirror=$(echo "$response" | head -n 1)
    if [ -z "$first_mirror" ]; then
        echo "  ❌ Error: No mirrors available"
        return 1
    fi
    
    # Test accessing the file through the mirror
    echo "  Testing access to: $first_mirror$file"
    http_code=$(curl -s -o /dev/null -w "%{http_code}" -I "$first_mirror$file")
    
    if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 302 ]; then
        echo "  ✅ Successfully accessed file (HTTP $http_code)"
        return 0
    else
        echo "  ❌ Failed to access file (HTTP $http_code)"
        return 1
    fi
}

# Main script
echo "Testing Mirrorbits setup at $MIRRORBITS_URL"
echo "========================================"

# Test basic Mirrorbits status
status=$(curl -s "$MIRRORBITS_URL/")
if [[ "$status" != *"Mirrorbits"* ]]; then
    echo "❌ Error: Could not connect to Mirrorbits"
    exit 1
fi

echo "✅ Connected to Mirrorbits"

# Test each file
all_tests_passed=true
for file in "${TEST_FILES[@]}"; do
    if ! test_file "$file"; then
        all_tests_passed=false
    fi
done

# Final result
echo -e "\nTest Summary"
echo "========================================"
if [ "$all_tests_passed" = true ]; then
    echo "✅ All tests passed!"
    echo "Mirrorbits is correctly set up and serving requests."
    echo -e "\nYou can access the web interface at: $MIRRORBITS_URL"
    echo "To add more mirrors, edit the add-mirrors.sh script and run it again."
else
    echo "❌ Some tests failed. Please check the output above for details."
    echo -e "\nTroubleshooting tips:"
    echo "1. Make sure Mirrorbits is running (use './mirrorbits-ctl status')"
    echo "2. Check if you've added mirrors (use './add-mirrors.sh')"
    echo "3. Verify your repository structure and permissions"
    echo "4. Check the Mirrorbits logs: docker-compose -f ../docker-compose.mirrorbits.yml logs mirrorbits"
    exit 1
fi
