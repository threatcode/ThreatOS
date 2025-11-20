# ThreatOS Desktop Variants

ThreatOS now supports multiple desktop environments, allowing users to choose their preferred desktop experience during installation. This document provides an overview of the available desktop variants and how to use them.

## Available Desktop Variants

1. **XFCE** - A lightweight and fast desktop environment that is easy to use and highly customizable.
2. **GNOME** - A modern and feature-rich desktop environment with a clean and intuitive interface.
3. **KDE Plasma** - A powerful and customizable desktop environment with a wide range of features and applications.

## Building a Specific Desktop Variant

To build a specific desktop variant, use the following command:

```bash
sudo ./build-threatos.sh --desktop [variant]
```

Where `[variant]` can be one of: `xfce`, `gnome`, or `kde`.

### Examples:

Build the XFCE variant (default):
```bash
sudo ./build-threatos.sh --desktop xfce
```

Build the GNOME variant:
```bash
sudo ./build-threatos.sh --desktop gnome
```

Build the KDE Plasma variant:
```bash
sudo ./build-threatos.sh --desktop kde
```

## Interactive Variant Selection

If you don't specify a variant, the build script will prompt you to select one interactively:

```bash
sudo ./build-threatos.sh --desktop
```

## Listing Available Variants

To list all available desktop variants:

```bash
./build-threatos.sh --list-variants
```

## Default Variant

If no variant is specified and the script is run in non-interactive mode, the default variant (XFCE) will be used.

## Building the Standard ISO

To build the standard (non-desktop) ISO, simply run the build script without any arguments:

```bash
sudo ./build-threatos.sh
```

## Output Files

- Desktop variants are built as disk images (`.img` files) in the `desktop-artifacts` directory.
- The standard ISO is built as an ISO file in the `iso-artifacts` directory.

## Creating a Bootable USB Drive

To create a bootable USB drive from a disk image:

```bash
sudo dd if=desktop-artifacts/threatos-desktop-*.img of=/dev/sdX bs=4M status=progress && sync
```

Replace `/dev/sdX` with your actual USB device (e.g., `/dev/sdb`).

**WARNING:** This will erase all data on the target device!
