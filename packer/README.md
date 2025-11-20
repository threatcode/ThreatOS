# ThreatOS Packer Configurations

This directory contains HashiCorp Packer configurations for building ThreatOS Vagrant boxes.

## Prerequisites

- [Packer](https://www.packer.io/downloads) 1.7.0 or later
- [Vagrant](https://www.vagrantup.com/downloads) 2.2.0 or later
- [VirtualBox](https://www.virtualbox.org/) or [libvirt](https://libvirt.org/) provider installed

## Usage

1. Install the required dependencies
2. Build the Vagrant box:
   ```bash
   packer build -var 'version=1.0.0' threatos.json
   ```
3. Add the box to Vagrant:
   ```bash
   vagrant box add threatos output/threatos-1.0.0.box --name threatos
   ```

## Configuration

- `threatos.json`: Main Packer template
- `scripts/`: Provisioning scripts
- `http/`: Preseed and other HTTP-served files
- `output/`: Output directory for built boxes (gitignored)
