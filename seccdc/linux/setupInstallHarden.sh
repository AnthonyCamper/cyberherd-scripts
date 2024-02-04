#!/bin/bash

if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1
fi

# Handling OS-SpecificThings

# Read the ID  line from /etc/os-release
id_like_line=$(grep '^ID=' /etc/os-release)

# Extract the value after the equals sign, removing potential quotes
operatingSystem=$(echo $id_like_line | cut -d'=' -f2 | tr -d '"')

# spread looks like this: "debian" covers debian and ajacent + ubuntu distros

####################################################
##################   DEBIAN & UBUNTU   ############################
####################################################



# Check if operatingSystem is empty
if [ -z "$operatingSystem" ]; then
    echo "The ID_LIKE line was not found or is empty."
else
    echo "Operating System base: $operatingSystem"
fi

if [ "$operatingSystem" = "debian" ]; then
    echo "Debian detected, use apt"

    # Get the system up to date
    sudo apt update -y
    sudo apt upgrade -y

# Install Git
    sudo apt install git -y
		
	# Install socat for snoopy
	sudo apt install socat -y
    # Install and enable fail2ban
    sudo apt install fail2ban -y
    sudo enable fail2ban 

    # Install UFW
    apt install ufw -y
fi

if [ "$operatingSystem" = "ubuntu" ]; then
    echo "Debian detected, use apt"

    # Get the system up to date
    sudo apt update -y
    sudo apt upgrade -y
		
	# Install socat for snoopy
	sudo apt install socat -y
    # Install and enable fail2ban
    sudo apt install fail2ban -y
    sudo enable fail2ban 

    # Install UFW
   sudo apt install ufw -y
fi
if [ "$operatingSystem" = "centos" ]; then
    echo "CentOS detected, use yum"

    # Get the system up to date
    sudo dnf update -y
    sudo yum update -y

# Install git
sudo yum install git -y
		
	# Install socat for snoopy
	sudo yum install socat -y
    # Install and enable fail2ban
    sudo yum install fail2ban -y
    sudo enable fail2ban 

    # Install UFW
    yum install ufw -y
fi
    # Setup UFW
    ## First, reset default rules
    ufw --force reset
    ufw disable
    ## Set default policies
    ufw default deny incoming
    ufw default allow outgoing

    ## Allow specific ports
    ufw allow 21    # FTP
    ufw allow 22    # SSH
    ufw allow 53    # DNS
    ufw allow 3306  # MySQL
    ufw allow 80    # HTTP

    # Enable UFW
    ufw --force enable

    # Check the status
    ufw status verbose

############################## BACKUPS
sudo mkdir /backup
mkdir /backup/initial

############################## BACKUP /etc

cp -r /etc /backup/initial/etc

############################## BACKUP /home

cp -r /home /backup/initial/home

################################## INSTALL SNOOPY
wget -O install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh &&
chmod 755 install-snoopy.sh &&
sudo ./install-snoopy.sh stable