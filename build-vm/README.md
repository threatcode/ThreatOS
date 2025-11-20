# ThreatOS VM Image Builder

This directory contains the build system for creating ThreatOS Virtual Machine (VM) images.

## Prerequisites

### For Native Build
- debos
- qemu-system-x86_64
- qemu-utils
- kvm
- libguestfs-tools
- make
- wget

### For Container Build
- Docker or Podman

## Building VM Images

### Native Build

1. Install the required dependencies:
   ```bash
   # On Debian/Ubuntu
   sudo apt-get update
   sudo apt-get install -y debos qemu-system-x86 qemu-utils libguestfs-tools make wget
   ```

2. Build the VM image:
   ```bash
   ./build.sh
   ```

### Container Build

1. Build using Docker:
   ```bash
   ./build-in-container.sh
   ```

   Or with Podman:
   ```bash
   CONTAINER_RUNTIME=podman ./build-in-container.sh
   ```

## Build Configuration

You can customize the build by setting environment variables or modifying the configuration files:

- `build-config` - Main build configuration
- `config/package-lists/` - Package lists for different variants
- `scripts/threatos-vm.yaml` - debos recipe for building the VM image

## Output

The built VM images will be available in the `output/` directory.

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.
