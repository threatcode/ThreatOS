# Base image
FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TERM=xterm-256color

# Install essential build tools and dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    # System tools
    apt-utils \
    ca-certificates \
    gnupg2 \
    software-properties-common \
    lsb-release \
    apt-transport-https \
    # Basic tools
    git \
    curl \
    wget \
    jq \
    yq \
    rsync \
    unzip \
    # Build tools
    build-essential \
    debootstrap \
    devscripts \
    equivs \
    fakeroot \
    live-build \
    squashfs-tools \
    genisoimage \
    xorriso \
    syslinux-utils \
    isolinux \
    syslinux \
    syslinux-efi \
    grub-common \
    grub2-common \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    # Development tools
    vim \
    neovim \
    less \
    sudo \
    tmux \
    htop \
    # Version control
    git-lfs \
    # Dependencies for build scripts
    python3 \
    python3-pip \
    python3-venv \
    # Shell tools
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    fzf \
    ripgrep \
    fd-find \
    # Security tools
    gpg \
    gpg-agent \
    openssh-client \
    # Network tools
    net-tools \
    iproute2 \
    dnsutils \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# Install additional tools via pip
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel && \
    pip3 install --no-cache-dir \
    ansible \
    ansible-lint \
    yamllint \
    pre-commit \
    black \
    flake8 \
    mypy

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
ARG USERNAME=threatdev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to the non-root user
USER $USERNAME

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
