# autopkgtest Configuration

This directory contains the configuration and test files for running autopkgtest on .deb packages.

## Directory Structure

```
tools/ci/autopkgtest/
├── control           # Main test control file - defines test dependencies and restrictions
├── README.md         # This documentation file
└── tests/            # Directory for test scripts and resources
    ├── common/       # Shared test utilities and helpers
    └── <package>/    # Package-specific test directories
        └── run       # Test script (executable)
```

### File Descriptions:
- `control`: Defines test dependencies, restrictions, and metadata for the test suite
- `tests/`: Contains all test scripts and resources
  - `common/`: Shared test utilities and helper functions
  - `<package>/`: Each package should have its own directory with a `run` script

## Adding Package-Specific Tests

For each package, you can add a test script at:
`/usr/share/<package-name>/tests/run`

### Example Test Script

```bash
#!/bin/sh
set -e

# Test that the package installed its files
if [ ! -f "/usr/bin/your-binary" ]; then
    echo "Error: Binary not found"
    exit 1
fi

# Test basic functionality
if ! your-binary --version; then
    echo "Error: Failed to get version"
    exit 1
fi

echo "All tests passed"
exit 0
```

## Running Tests Locally

To test a package locally:

```bash
# Install autopkgtest
sudo apt-get install autopkgtest

# Run tests on a package
cd /path/to/package
autopkgtest . -- null
```

## Monitoring Builds and Workflows

### Monitoring the Build Process

1. **Access GitHub Actions**:
   - Go to: [GitHub Actions](https://github.com/threatcode/ThreatOS/actions)
   - Or navigate through: Repository → Actions tab

2. **Locate the Workflow**:
   - Find "Build LXC Containers" in the workflow list
   - Click to view the latest run

3. **Monitor Progress**:
   - Real-time build logs are available
   - Green checkmarks (✓) indicate completed steps
   - Red X (✗) indicates failures
   - Click on any step to view detailed logs

### After Build Completion

- **Successful Build**:
  - Container image available at: `ghcr.io/threatcode/ThreatOS/lxc-base:latest`
  - Image tagged with both `latest` and the commit SHA

- **Failed Build**:
  - Review error logs in the failed step
  - Common issues include dependency conflicts or build timeouts

### Triggering the autopkgtest Workflow

1. **Prerequisites**:
   - Ensure LXC container build is complete
   - Verify you have write access to the repository

2. **Manual Trigger**:
   - Go to: Repository → Actions → "Run autopkgtest" workflow
   - Click "Run workflow" (green button)
   - Optionally specify a branch or commit
   - Click "Run workflow" to start

3. **Scheduled Runs**:
   - Nightly tests run automatically
   - Can be configured in `.github/workflows/autopkgtest.yml`

4. **Monitoring Test Execution**:
   - View real-time test output
   - Download test artifacts for detailed analysis
   - Set up notifications for test results

## Test Restrictions

### Environment Constraints

1. **Containerization**:
   - Tests run in an isolated LXC container
   - Based on the latest stable Debian release
   - Systemd is available but runs in a container context

2. **Privileges**:
   - Tests run with root privileges
   - Avoid unnecessary use of `sudo`
   - Be cautious with system modifications

3. **Resource Limits**:
   - **Disk Space**: Limited to 2GB by default
     - Clean up temporary files
     - Avoid large test data sets
   - **Memory**: 2GB RAM available
   - **CPU**: 2 vCPUs allocated
   - **Timeout**: 30 minutes per test

4. **Network Access**:
   - Outbound HTTP/HTTPS allowed
   - No inbound connections
   - Rate limiting may apply to external services

5. **Filesystem**:
   - Ephemeral storage (changes not persisted)
   - Read-only root filesystem (except `/tmp` and `/var/tmp`)
   - No access to host system files

## Best Practices

### Test Design

1. **Performance**:
   - Keep individual tests under 5 minutes
   - Test one feature per test case
   - Use test fixtures for setup/teardown

2. **Reliability**:
   - Make tests idempotent (can be run multiple times)
   - Handle cleanup in `trap` or `teardown` functions
   - Avoid test dependencies (each test should be independent)

3. **Error Handling**:
   - Include descriptive error messages
   - Use `set -euo pipefail` in shell scripts
   - Test both success and failure cases

4. **Code Quality**:
   - Follow shell style guide (Google Shell Style Guide recommended)
   - Use `shellcheck` for static analysis
   - Document test purpose and requirements

5. **Security**:
   - Never hardcode credentials
   - Use environment variables for configuration
   - Follow principle of least privilege

6. **Maintainability**:
   - Group related tests in separate files
   - Use helper functions for common operations
   - Add comments explaining complex test logic

### Example Test Structure

```bash
#!/bin/sh
set -euo pipefail

# Test: Verify package installation and basic functionality
# Dependencies: package-name

# Setup
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

# Test 1: Verify binary exists
test -x /usr/bin/package-name || \
    { echo "Error: package-name binary not found" >&2; exit 1; }

# Test 2: Check version
package-name --version >/dev/null 2>&1 || \
    { echo "Error: Failed to get version" >&2; exit 1; }

# Test 3: Basic functionality test
output=$(package-name --test)
echo "$output" | grep -q 'expected output' || \
    { echo "Error: Unexpected output" >&2; exit 1; }

echo "All tests passed"
exit 0
```
