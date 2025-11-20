## REF: https://hub.docker.com/_/debian
# Use buildx to support multi-architecture builds
# Supported platforms: linux/amd64, linux/arm64
ARG TARGETARCH=amd64
FROM --platform=linux/${TARGETARCH} docker.io/debian:stable-slim

# Set architecture-specific variables
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

# Set architecture-specific package names
RUN case "${TARGETARCH}" in \
        amd64) \
            ARCH_SUFFIX=amd64 \
            ;; \
        arm64) \
            ARCH_SUFFIX=arm64 \
            ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 \
            ;; \
    esac

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        gnupg \
        && \
    rm -rf /var/lib/apt/lists/*

# Install ThreatOS archive keyring
RUN set -eux; \
    KEYRING_PKG_URL=$(wget -nv -O - \
        "https://threatcode.github.io/threatos/debian/dists/stable/main/binary-${TARGETARCH}/Packages.gz" | \
        gzip -dc | \
        grep "^Filename: .*/threatos-archive-keyring_.*_all.deb" | \
        head -n 1 | \
        awk '{print $2}') && \
    wget -nv "https://threatcode.github.io/threatos/debian/${KEYRING_PKG_URL}" && \
    sha256sum threatos-archive-keyring_*_all.deb && \
    dpkg -i threatos-archive-keyring_*_all.deb && \
    rm -f threatos-archive-keyring_*_all.deb

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        debootstrap \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set default command
CMD ["/bin/bash"]
