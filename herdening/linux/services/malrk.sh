#!/bin/bash

# Ensure the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

#Using rkhunter alone does not guarantee that a system is not compromised. Running additional tests, such as chkrootkit, is recommended.

#Install dependencies
if [ "$operatingSystem" = "debian" ] || [ "$operatingSystem" = "ubuntu" ]; then
    echo "$operatingSystem detected, using apt"
    sudo apt install rkhunter -y
    sudo apt install chkrootkit -y


elif [ "$operatingSystem" = "centos" ]; then
    echo "CentOS detected, using yum"
    #All files required for installation of RKHunter are contained in the EPEL repository.
    sudo yum install epel-release -y
    rkhunter --update
fi

#rkhunter


#chkrootkit


#debsums


#clamav
