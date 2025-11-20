# ThreatOS Build Environment
# Based on Debian Bookworm
FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    debootstrap \
    debian-archive-keyring \
    debian-keyring \
    dosfstools \
    fdisk \
    file \
    gcc \
    git \
    gnupg \
    grub-efi-amd64-bin \
    grub-pc-bin \
    isolinux \
    libfile-fcntllock-perl \
    live-build \
    locales \
    mtools \
    openssh-client \
    p7zip-full \
    rsync \
    sudo \
    syslinux-common \
    syslinux-efi \
    wget \
    xorriso \
    && rm -rf /var/lib/apt/lists/*

# Set up build user
RUN useradd -m -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder && \
    chmod 0440 /etc/sudoers.d/builder

# Create build directory and set permissions
RUN mkdir -p /build/threatos && \
    chown -R builder:builder /build

# Switch to builder user
USER builder
WORKDIR /build/threatos

# Default command
CMD ["/bin/bash"]
