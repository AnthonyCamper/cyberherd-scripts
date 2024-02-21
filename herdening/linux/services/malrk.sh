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
echo "Installing Dependencies please wait..."

if [ "$operatingSystem" = "debian" ] || [ "$operatingSystem" = "ubuntu" ]; then
    echo "$operatingSystem detected, using apt..."
    sudo apt install rkhunter -y --fix-missing -qq
    sudo apt install chkrootkit -y -qq
    sudo apt install debsums -y -qq
    
    echo -e "\n\nScanning for binaries that are malicious/have been tampered with:"
    sudo debsums -ac 2>&1 | grep -v missing

    echo -e "\n\nRKH Scanning for known potential Root Kits:"
    rkhunter --check --sk --rwo

    echo -e "\n\nCHK Scanning for known potential Root Kits:"
    chkrootkit -q | grep INFECTED
    
elif [ "$operatingSystem" = "centos" ]; then
    echo "$operatingSystem detected, using yum..."

elif [ "$operatingSystem" = "fedora" ]; then
    echo "$operatingSystem detected, using dnf..."

elif [ "$operatingSystem" = "openbsd" ]; then
    echo "$operatingSystem detected, using pdk_add..."

fi
