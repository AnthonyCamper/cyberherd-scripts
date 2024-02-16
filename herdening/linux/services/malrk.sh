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

#Install dependencies
if [ "$operatingSystem" = "debian" ] || [ "$operatingSystem" = "ubuntu" ]; then
    echo "$operatingSystem detected, using apt"
    sudo apt install debsums -y
    sudo apt install rkhunter -y 
    sudo apt install chkrootkit -y

elif [ "$operatingSystem" = "centos" ]; then
    echo "CentOS detected, using yum"
    sudo yum install epel-release -y #All files required for installation of RKHunter are contained in the EPEL repository.
    sudo yum install rkhunter -y
fi

#rkhunter
# You have to config rkhunter.conf in order to use
# /etc/rkhunter.conf


#chkrootkit


#debsums


#clamav
