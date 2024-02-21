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
echo -e "Installing Dependencies please wait...\n\n"

if [ "$operatingSystem" = "debian" ] || [ "$operatingSystem" = "ubuntu" ]; then
    echo "$operatingSystem detected, using apt..."
    sudo apt install rkhunter -y --fix-missing -qq
    sudo apt install chkrootkit -y -qq
    sudo apt install debsums -y -qq

    if grep -q 'WEB_CMD="/bin/false"' /etc/rkhunter.conf; then
        sudo sed -i 's|^WEB_CMD="/bin/false"|WEB_CMD=""|' /etc/rkhunter.conf
        sudo sed -i 's/^UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/' /etc/rkhunter.conf
        sudo sed -i 's/^MIRRORS_MODE=1/MIRRORS_MODE=0/' /etc/rkhunter.conf
    fi

    echo -e "\n\nScanning for binaries that are malicious/have been tampered with:\n--(rkhunter is false positive, ignore)--"
    sudo debsums -ac 2>&1 | grep -v missing

    echo -e "\n\nRKH Scanning for known potential Root Kits:"
    rkhunter --update -q
    rkhunter --check --sk --rwo

    echo -e "\n\nCHK Scanning for known potential Root Kits:"
    chkrootkit -q | grep INFECTED
    
elif [ "$operatingSystem" = "centos" ]; then
    echo "$operatingSystem detected, using yum..."
    sudo yum install epel-release -y -q
    sudo yum install rkhunter -y -q

    if grep -q 'WEB_CMD="/bin/false"' /etc/rkhunter.conf; then
        sudo sed -i 's|^WEB_CMD="/bin/false"|WEB_CMD=""|' /etc/rkhunter.conf
        sudo sed -i 's/^UPDATE_MIRRORS=0/UPDATE_MIRRORS=1/' /etc/rkhunter.conf
        sudo sed -i 's/^MIRRORS_MODE=1/MIRRORS_MODE=0/' /etc/rkhunter.conf
    fi

    echo -e "\n\nRKH Scanning for known potential Root Kits:"
    rkhunter --update -q
    rkhunter --check --sk --rwo
    
elif [ "$operatingSystem" = "fedora" ]; then
    echo "$operatingSystem detected, using dnf..."

elif [ "$operatingSystem" = "openbsd" ]; then
    echo "$operatingSystem detected, using pdk_add..."

fi
