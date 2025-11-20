# Archvsync for ThreatOS

This directory contains the Archvsync implementation for synchronizing Debian/Ubuntu package repositories in the ThreatOS environment.

## Overview

Archvsync provides two main scripts:

1. `ftpsync` - Synchronizes a Debian archive using rsync
2. `runmirrors` - Notifies leaf nodes of available updates

## Prerequisites

- rsync
- bash
- sendmail (for email notifications in runmirrors)
- Proper filesystem permissions to write to the target directory

## Installation

1. Copy the scripts to a directory in your PATH (e.g., `/usr/local/bin`):
   ```bash
   sudo cp ftpsync runmirrors /usr/local/bin/
   sudo chmod +x /usr/local/bin/{ftpsync,runmirrors}
   ```

2. Create configuration directories:
   ```bash
   sudo mkdir -p /etc/archvsync
   sudo mkdir -p /var/log/archvsync
   sudo mkdir -p /var/lock/archvsync
   ```

3. Copy and customize the example configuration files:
   ```bash
   sudo cp example-ftpsync.conf /etc/archvsync/ftpsync.conf
   sudo cp example-runmirrors.conf /etc/archvsync/runmirrors.conf
   ```

## Configuration

### ftpsync.conf

Edit `/etc/archvsync/ftpsync.conf` to configure the rsync source and destination:

```bash
# Remote rsync host (Debian archive)
RSYNC_HOST="deb.debian.org"
RSYNC_PATH="debian"

# Local target directory
TARGET="/srv/mirrors/debian"

# Additional rsync options
RSYNC_OPTS=(
    "-aH"
    "--partial"
    "--progress"
    "--no-motd"
    "--timeout=600"
    "--delay-updates"
    "--delete-after"
    "--delete-excluded"
    "--bwlimit=10M"
    "--no-owner"
    "--no-group"
)
```

### runmirrors.conf

Edit `/etc/archvsync/runmirrors.conf` to configure mirror notifications:

```bash
# Email notifications
MAIL_TO="admin@example.com"
MAIL_FROM="archvsync@$(hostname -f)"
SEND_EMAIL="yes"

# List of mirrors to notify
MIRRORS=(
    "mirror1.example.com"
    "mirror2.example.com"
)

# SSH options for connecting to mirrors
SSH_OPTS=(
    "-o BatchMode=yes"
    "-o ConnectTimeout=10"
    "-o StrictHostKeyChecking=yes"
)
```

## Usage

### Synchronizing a Repository

To synchronize a Debian repository:

```bash
sudo ftpsync
```

### Notifying Mirrors

To notify all mirrors of updates:

```bash
sudo runmirrors
```

## Integration with Mirrorbits

If you're using Mirrorbits (recommended), you can configure it to work with Archvsync by pointing it to the same target directory used in `ftpsync.conf`.

## Logs

Logs are stored in `/var/log/archvsync/` with filenames like `ftpsync-YYYYMMDD.log` and `runmirrors-YYYYMMDD.log`.

## Security Considerations

1. Run the sync as a non-root user with minimal privileges
2. Use SSH keys for authentication with mirrors
3. Set appropriate file permissions on the target directory
4. Consider using a bandwidth limit to avoid saturating your network
5. Monitor disk space usage, especially for large repositories

## License

This software is licensed under the same terms as ThreatOS.
