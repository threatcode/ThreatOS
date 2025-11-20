# ThreatOS WSL Rootfs Builder

This directory contains the necessary files to build a Windows Subsystem for Linux (WSL) root filesystem for ThreatOS.

## Prerequisites

### For Native Build
- A Linux system with root access
- Required packages: debootstrap, wget, tar, gzip, sudo, coreutils
- At least 5GB of free disk space
- For building on Windows, use WSL 2 with Ubuntu 20.04 or later

### For Container Build
- Docker or Podman installed and configured
- At least 8GB of free disk space (container overhead)
- Sudo privileges (for managing containers)

## Building the WSL Rootfs

### Native Build

1. Clone the ThreatOS repository if you haven't already:
   ```bash
   git clone https://github.com/threatcode/ThreatOS.git
   cd ThreatOS/wsl
   ```

2. Make the build scripts executable:
   ```bash
   chmod +x build.sh build-in-container.sh
   ```

3. Run the build script with root privileges:
   ```bash
   sudo ./build.sh
   ```

### Container Build (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/threatcode/ThreatOS.git
   cd ThreatOS/wsl
   ```

2. Run the container build script:
   ```bash
   ./build-in-container.sh
   ```
   
   This will automatically build a container image and run the build process inside it.
   
   > **Note**: The container build requires either Docker or Podman to be installed.
   > You can force a specific container runtime by setting the `CONTAINER` environment variable:
   > ```bash
   > CONTAINER=docker ./build-in-container.sh
   > # or
   > CONTAINER=podman ./build-in-container.sh
   > ```

1. Clone the ThreatOS repository if you haven't already:
   ```bash
   git clone https://github.com/threatcode/ThreatOS.git
   cd ThreatOS
   ```

2. Run the build script with root privileges:
   ```bash
   sudo ./build.sh
   ```
   
   Or to build using a container (recommended for better isolation):
   ```bash
   ./build-in-container.sh
   ```

3. The script will:
   - Install the base system
   - Configure WSL-specific settings
   - Create a rootfs tarball
   - Generate an installation script for Windows

## Installing on Windows

1. Copy the generated files from the `wsl/` directory to your Windows machine
2. Open PowerShell as Administrator
3. Navigate to the directory containing the files
4. Run the installation script:
   ```powershell
   .\install.ps1
   ```

## Customization

### Build Options

You can customize the build by setting environment variables:

```bash
# Set the version number
VERSION=1.0.0 ./build.sh

# Set the target architecture (default: amd64)
ARCH=arm64 ./build.sh

# Set the mirror URL (default: http://deb.debian.org/debian)
MIRROR=http://ftp.debian.org/debian ./build.sh

# Build with a specific desktop environment (default: none)
# Options: e17, gnome, i3, kde, lxde, mate, xfce, none
DESKTOP=gnome ./build.sh
```

### Package Selection

Edit the following files to customize the installed packages:

- `build-scripts/package-lists/wsl.list.chroot` - WSL-specific packages
- `build-scripts/package-lists/standard.list.chroot` - Base system packages

## Troubleshooting

### Common Issues

1. **Build fails with debootstrap errors**
   - Ensure you have a stable internet connection
   - Try using a different mirror by setting the `MIRROR` environment variable

2. **WSL import fails on Windows**
   - Make sure WSL 2 is enabled (run `wsl --set-default-version 2` in PowerShell)
   - Run PowerShell as Administrator

3. **Systemd not working**
   - WSL 2 is required for systemd support
   - Add `[boot]\nsystemd=true` to `/etc/wsl.conf` and restart WSL

## License

This project is licensed under the same license as ThreatOS. See the main LICENSE file for details.
