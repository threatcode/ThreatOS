# autopkgtest Configuration

This directory contains the configuration and test files for running autopkgtest on .deb packages.

## Directory Structure

```
tools/ci/autopkgtest/
├── control           # Main test control file
└── README.md         # This file
```

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

## Test Restrictions

The test environment has the following restrictions:
- Runs in an LXC container
- Has root access
- Network access is available
- Limited disk space (be mindful of test data size)

## Best Practices

1. Keep tests small and fast
2. Clean up after tests
3. Don't modify system state permanently
4. Make tests idempotent
5. Include meaningful error messages
