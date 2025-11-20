#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_SCRIPTS_DIR="${SCRIPT_DIR}/build-scripts"
WSL_DIR="${SCRIPT_DIR}/wsl"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "[!] This script requires root privileges. Please run with sudo."
    exit 1
fi

# Load build configuration
if [ -f "${BUILD_SCRIPTS_DIR}/build-config" ]; then
    source "${BUILD_SCRIPTS_DIR}/build-config"
else
    echo "[!] Error: build-config not found in ${BUILD_SCRIPTS_DIR}"
    exit 1
fi

# Create necessary directories
mkdir -p "${WSL_DIR}" "${CACHE_DIR}" "${BUILD_DIR}"

# Function to clean up on exit
cleanup() {
    echo "[*] Cleaning up..."
    umount -f "${BUILD_DIR}/dev" 2>/dev/null || true
    umount -f "${BUILD_DIR}/proc" 2>/dev/null || true
    umount -f "${BUILD_DIR}/sys" 2>/dev/null || true
    rm -rf "${BUILD_DIR}"
}
trap cleanup EXIT

# Install base system
echo "[*] Installing base system..."
${BUILD_SCRIPTS_DIR}/build.sh --variant wsl --arch amd64

# Create WSL specific files
echo "[*] Setting up WSL configuration..."
cat > "${BUILD_DIR}/etc/wsl.conf" << EOF
[automount]
enabled = true
options = "metadata,umask=22,fmask=11"
mountFsTab = false

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[user]
default = ${USERNAME}
EOF

# Create WSL startup script
cat > "${BUILD_DIR}/usr/local/bin/start-wsl" << 'EOF'
#!/bin/bash
# Set up environment for WSL

# Set hostname
if [ -z "${WSL_DISTRO_NAME}" ]; then
    export WSL_DISTRO_NAME="threatos"
fi

# Start systemd if not already running
if [ -z "$(ps -eo comm | grep systemd)" ]; then
    exec /lib/systemd/systemd --system --unit=basic.target
fi
EOF
chmod +x "${BUILD_DIR}/usr/local/bin/start-wsl"

# Create WSL entry point
echo "[*] Creating WSL entry point..."
cat > "${BUILD_DIR}/init" << 'EOF'
#!/bin/sh
# WSL init script

# Mount required filesystems
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -o bind /dev /dev
mount -t devpts /dev/pts

# Start the system
if [ -x /usr/local/bin/start-wsl ]; then
    exec /usr/local/bin/start-wsl
else
    exec /bin/bash
fi
EOF
chmod +x "${BUILD_DIR}/init"

# Create rootfs tarball
echo "[*] Creating rootfs tarball..."
cd "${BUILD_DIR}"
tar -czf "${WSL_DIR}/threatos-wsl-rootfs-${VERSION}.tar.gz" .

# Create WSL distribution package
echo "[*] Creating WSL distribution package..."
cat > "${WSL_DIR}/install.ps1" << 'EOF'
# PowerShell script to install ThreatOS WSL
param(
    [string]$DistroName = "ThreatOS",
    [string]$InstallLocation = "$env:USERPROFILE\\ThreatOS"
)

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges. Please run as administrator."
    exit 1
}

# Check if WSL is enabled
$wslEnabled = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

if ($wslEnabled.State -ne "Enabled") {
    Write-Host "Enabling Windows Subsystem for Linux..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Write-Host "Please restart your computer and run this script again."
    exit 0
}

# Create installation directory
New-Item -ItemType Directory -Force -Path $InstallLocation | Out-Null

# Import the WSL distribution
Write-Host "Installing ThreatOS WSL distribution..."
$distroPath = "$PSScriptRoot\\threatos-wsl-rootfs-${VERSION}.tar.gz"
wsl --import $DistroName $InstallLocation $distroPath

# Set default user
$distroName = (Get-ChildItem -Path "$env:LOCALAPPDATA\\Packages" -Filter *ThreatOS* | Select-Object -First 1).Name
if ($distroName) {
    $distroId = (Get-ChildItem -Path "$env:LOCALAPPDATA\\Packages\\$distroName\\LocalState\\ext4.vhdx").FullName
    wsl --set-default-version 2
    wsl --set-version $DistroName 2
    wsl --set-default $DistroName
    
    Write-Host "ThreatOS WSL has been installed successfully!"
    Write-Host "To start ThreatOS WSL, run: wsl -d $DistroName"
} else {
    Write-Host "Installation completed, but could not set default user."
    Write-Host "You may need to manually configure the default user by running:"
    Write-Host "wsl -d $DistroName -u root"
    Write-Host "And then run: echo '${USERNAME}:x:1000:1000::/home/${USERNAME}:/bin/bash' > /etc/passwd"
}
EOF

# Create WSL package list
mkdir -p "${BUILD_SCRIPTS_DIR}/package-lists"
cat > "${BUILD_SCRIPTS_DIR}/package-lists/wsl.list.chroot" << 'EOF'
# WSL specific packages
systemd
systemd-sysv
locales
sudo
curl
wget
git
nano
vim
tmux
htop
net-tools
iproute2
dnsutils
iputils-ping
openssh-server
ca-certificates
EOF

echo "[+] WSL rootfs build complete!"
echo "[+] WSL rootfs: ${WSL_DIR}/threatos-wsl-rootfs-${VERSION}.tar.gz"
echo "[+] To install on Windows, run the following command in PowerShell as Administrator:"
echo "    .\\install.ps1"
