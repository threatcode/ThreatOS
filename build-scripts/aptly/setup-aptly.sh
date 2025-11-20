#!/bin/bash
set -e

# Install Aptly
apt-get update
apt-get install -y gnupg2 aptly

# Create Aptly configuration
mkdir -p /etc/aptly
cat > /etc/aptly.conf << EOF
{
    "rootDir": "/var/lib/aptly",
    "downloadConcurrency": 4,
    "downloadSpeedLimit": 0,
    "architectures": ["amd64"],
    "dependencyFollowSuggests": false,
    "dependencyFollowRecommends": false,
    "dependencyFollowAllVariants": false,
    "dependencyFollowSource": false,
    "gpgDisableSign": false,
    "gpgDisableVerify": false,
    "downloadSourcePackages": false,
    "ppaDistributorID": "debian",
    "ppaCodename": "",
    "skipLegacyPool": true,
    "skipContentsPublishing": false,
    "skipBz2": false,
    "skipCleanup": false,
    "skipSigning": false,
    "S3PublishEndpoints": {}
}
EOF

# Create repositories
aptly repo create -distribution=bookworm -component=main threatos-main
aptly repo create -distribution=bookworm -component=contrib threatos-contrib
aptly repo create -distribution=bookworm -component=non-free threatos-nonfree

# Add mirrors
aptly mirror create -architectures=amd64 bookworm-main http://deb.debian.org/debian bookworm main
aptly mirror create -architectures=amd64 bookworm-contrib http://deb.debian.org/debian bookworm contrib
aptly mirror create -architectures=amd64 bookworm-nonfree http://deb.debian.org/debian bookworm non-free

# Import packages from mirrors
aptly mirror update bookworm-main
aptly mirror update bookworm-contrib
aptly mirror update bookworm-nonfree

# Publish repositories
aptly publish repo -distribution=bookworm -architectures=amd64 threatos-main
aptly publish repo -distribution=bookworm -architectures=amd64 threatos-contrib
aptly publish repo -distribution=bookworm -architectures=amd64 threatos-nonfree
