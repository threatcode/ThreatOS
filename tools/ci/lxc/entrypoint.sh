#!/bin/bash
set -e

# Start systemd
if [ -d /sys/fs/cgroup/systemd ] ; then
    mount -t cgroup -o none,name=systemd cgroup /sys/fs/cgroup/systemd
fi

# Start dbus
mkdir -p /run/dbus
dbus-daemon --system --fork

# Start systemd-networkd
systemctl start systemd-networkd

# Set up LXC bridge
if ! ip link show lxcbr0 &> /dev/null; then
    brctl addbr lxcbr0
    ip addr add 10.0.3.1/24 dev lxcbr0
    ip link set lxcbr0 up
    
    # Enable NAT
    iptables -t nat -A POSTROUTING -s 10.0.3.0/24 ! -d 10.0.3.0/24 -j MASQUERADE
    echo 1 > /proc/sys/net/ipv4/ip_forward
fi

# Keep the container running
tail -f /dev/null
