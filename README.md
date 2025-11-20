# ThreatOS

ThreatOS is a security-focused Linux distribution designed for penetration testing, security research, and digital forensics.

## Features

- Pre-installed security tools
- Custom hardened kernel
- Live bootable environment
- Privacy-focused defaults
- Regular security updates

## Getting Started

### Prerequisites

- A Linux-based system (Debian/Ubuntu recommended)
- Minimum 4GB RAM (8GB+ recommended)
- 20GB free disk space
- Internet connection

### Building ThreatOS

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/ThreatOS.git
   cd ThreatOS
   ```

2. Install dependencies:
   ```bash
   sudo apt-get update && sudo apt-get install -y \
       live-build squashfs-tools genisoimage syslinux-utils \
       isolinux syslinux syslinux-efi grub-pc grub-efi-amd64 \
       grub-efi-ia32 grub-common grub2-common mtools xorriso wget
   ```

3. Start the build:
   ```bash
   sudo ./build-threatos.sh
   ```

4. The final ISO will be available in the `iso-artifacts` directory.

### Creating a Bootable USB

```bash
sudo dd if=iso-artifacts/threatos-*.iso of=/dev/sdX bs=4M status=progress && sync
```

Replace `/dev/sdX` with your USB device (e.g., `/dev/sdb`).

## Directory Structure

- `build-scripts/`: Build system scripts
- `config/`: Live build configuration
  - `hooks/`: Build hooks
  - `package-lists/`: Package lists
  - `includes.*/`: Additional files to include in the build
- `iso-artifacts/`: Output directory for built ISOs

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security

Please report any security issues to security@example.com.

## Acknowledgments

- Debian Live Project
- Kali Linux
- Parrot Security OS
- All open-source tools included in ThreatOS
