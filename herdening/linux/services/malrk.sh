#!/bin/bash

# Ensure the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

id_like_line=$(grep '^ID=' /etc/os-release)

operatingSystem=$(echo $id_like_line | cut -d'=' -f2 | tr -d '"')

if [ -z "$operatingSystem" ]; then
    echo "The ID_LIKE line was not found or is empty."
else
    echo "Operating System base: $operatingSystem"
fi

echo "This may take a while to run..."

#Install dependencies
if [ "$operatingSystem" = "debian" ] || [ "$operatingSystem" = "ubuntu" ]; then
    echo "$operatingSystem detected, using apt"
    sudo apt install rkhunter -y --fix-missing
    sudo apt install chkrootkit -y
    sudo apt install debsums -y
    
    echo "The following binaries are malicious/have been tampered with:"
    sudo debsums -ac 2>&1 | grep -v missing

    echo "RKH Scanning for known potential Root Kits:"
    rkhunter --check --sk --rwo

    echo "CHK Scanning for known potential Root Kits 2:"
    chkrootkit -q | grep INFECTED
    
elif [ "$operatingSystem" = "centos" ]; then
    echo "CentOS detected, using yum"

elif [ "$operatingSystem" = "fedora" ]; then
    echo "Fedora detected, using dnf"

elif [ "$operatingSystem" = "openbsd" ]; then
    echo "OpenBSD detected, using pdk_add"

fi
