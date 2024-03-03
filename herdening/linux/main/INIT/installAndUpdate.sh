#!/bin/bash

# Determine the package manager
if command -v apt > /dev/null; then
    pkgManager="apt"
elif command -v dnf > /dev/null; then
    pkgManager="dnf"
elif command -v yum > /dev/null; then
    pkgManager="yum"
else
    echo "No known package manager found. Script will exit."
    exit 1
fi

echo "Using package manager: $pkgManager"

# Define a generic update, install, and remove function
update_system() {
    sudo $pkgManager update -y
    if [ "$pkgManager" = "apt" ]; then
        sudo $pkgManager upgrade -y
    fi
}

install_package() {
    sudo $pkgManager install -y "$@"
}

remove_package() {
    if [ "$pkgManager" = "apt" ]; then
        sudo $pkgManager purge -y "$@"
    else
        sudo $pkgManager remove -y "$@"
    fi
}

enable_service() {
    sudo systemctl enable "$@"
    sudo systemctl start "$@"
}

# Update system
update_system

# Install packages
install_package rsyslog git socat fail2ban zip net-tools htop e2fsprogs epel-release uf
remove_package cron

# Special handling for UFW, considering its availability
if [ "$pkgManager" = "apt" ] || [ "$pkgManager" = "yum" ] && command -v ufw > /dev/null; then
    install_package ufw
fi

# Enable and start fail2ban
enable_service fail2ban

echo "Package installation and configuration completed."
