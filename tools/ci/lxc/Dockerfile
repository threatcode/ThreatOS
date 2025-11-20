FROM ubuntu:22.04

# Install LXC and dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    lxc \
    lxc-templates \
    lxc-utils \
    bridge-utils \
    debootstrap \
    libvirt-clients \
    libvirt-daemon-system \
    iptables \
    ebtables \
    dnsmasq-base \
    uidmap \
    dbus \
    systemd \
    systemd-container \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Configure LXC
RUN echo 'lxc.apparmor.profile = unconfined' >> /etc/lxc/default.conf \
    && echo 'lxc.mount.auto = proc:rw sys:rw' >> /etc/lxc/default.conf \
    && echo 'lxc.cgroup.devices.allow = a' >> /etc/lxc/default.conf

# Create a non-root user for LXC
RUN useradd -m lxcuser -G lxc,sudo \
    && echo 'lxcuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/lxcuser

# Set up LXC networking
RUN mkdir -p /etc/lxc/networks/ \
    && echo 'lxc.net.0.type = veth' > /etc/lxc/networks/lxctest.network \
    && echo 'lxc.net.0.link = lxcbr0' >> /etc/lxc/networks/lxctest.network \
    && echo 'lxc.net.0.flags = up' >> /etc/lxc/networks/lxctest.network

# Configure systemd to run in container
RUN rm -f /usr/sbin/policy-rc.d \
    && echo 'exit 0' > /usr/sbin/policy-rc.d \
    && chmod +x /usr/sbin/policy-rc.d

# Set up the entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
