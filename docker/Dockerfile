# ThreatOS Build Environment
FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TERM=xterm-256color \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install build dependencies
RUN apt-get update && apt-get install -y \
    live-build \
    squashfs-tools \
    genisoimage \
    syslinux-utils \
    isolinux \
    syslinux \
    syslinux-efi \
    grub-pc \
    grub-common \
    grub2-common \
    mtools \
    xorriso \
    wget \
    git \
    curl \
    vim \
    less \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN useradd -m -s /bin/bash builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder

# Set working directory and switch to non-root user
WORKDIR /threatos
USER builder

# Copy build scripts and configuration
COPY --chown=builder:builder . /threatos/

# Set default command
CMD ["/bin/bash"]
