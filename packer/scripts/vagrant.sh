#!/bin/bash

# Configure system for Vagrant
set -e

# Create vagrant user if not exists
if ! id -u vagrant >/dev/null 2>&1; then
    echo "Creating vagrant user..."
    useradd --create-home -s /bin/bash vagrant
    echo "vagrant:vagrant" | chpasswd
    echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
    chmod 0440 /etc/sudoers.d/vagrant
fi

# Install VirtualBox Guest Additions
if [ -f /media/cdrom/VBoxLinuxAdditions.run ]; then
    echo "Installing VirtualBox Guest Additions..."
    mount -t vboxsf -o uid=`id -u vagrant`,gid=`id -g vagrant` vagrant /vagrant
    /media/cdrom/VBoxLinuxAdditions.run || true
fi

# Configure SSH for Vagrant
echo "Configuring SSH for Vagrant..."
mkdir -p /home/vagrant/.ssh
curl -o /home/vagrant/.ssh/authorized_keys -kL 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys

# Disable DNS resolution for SSH login
echo "Disabling DNS resolution for SSH..."
echo "UseDNS no" >> /etc/ssh/sshd_config

# Enable passwordless sudo for Vagrant
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Set up shared folders in /vagrant
echo "Setting up shared folders..."
mkdir -p /vagrant
chown vagrant:vagrant /vagrant

# Configure GRUB to boot faster
echo "Configuring GRUB..."
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"/' /etc/default/grub
update-grub

# Disable automatic updates
echo 'APT::Periodic::Update-Package-Lists "0";' > /etc/apt/apt.conf.d/20auto-upgrades
echo 'APT::Periodic::Unattended-Upgrade "0";' >> /etc/apt/apt.conf.d/20auto-upgrades

echo "Vagrant configuration complete."
