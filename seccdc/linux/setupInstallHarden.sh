#!/bin/bash

if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1
fi

# Define an array of ports to allow through UFW
allowPorts=(21 22 53 3306 80 443)

# Handling OS-Specific Things

# Read the ID line from /etc/os-release
id_like_line=$(grep '^ID=' /etc/os-release)

# Extract the value after the equals sign, removing potential quotes
operatingSystem=$(echo $id_like_line | cut -d'=' -f2 | tr -d '"')

# Check if operatingSystem is empty
if [ -z "$operatingSystem" ]; then
    echo "The ID_LIKE line was not found or is empty."
else
    echo "Operating System base: $operatingSystem"
fi

# Install common utilities and configure services based on the OS
if [ "$operatingSystem" = "debian" ] || [ "$operatingSystem" = "ubuntu" ]; then
    echo "$operatingSystem detected, using apt"

    # Get the system up to date
    sudo apt update -y
    sudo apt upgrade -y

    # Install Git
    sudo apt install git -y

    # Install socat for snoopy
    sudo apt install socat -y

    # Install and configure fail2ban
    sudo apt install fail2ban -y
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban

    # Install UFW
    sudo apt install ufw -y

elif [ "$operatingSystem" = "centos" ]; then
    echo "CentOS detected, using yum"

    # Get the system up to date
    sudo dnf update -y
    sudo yum update -y

    # Install git
    sudo yum install git -y

    # Install socat for snoopy
    sudo yum install socat -y

    # Install and configure fail2ban
    sudo yum install fail2ban -y
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban

    # Install UFW
    sudo yum install ufw -y
fi

############################## BACKUPS
echo "Creating backups..."
sudo mkdir -p /backup/initial

############################## BACKUP /etc
cp -r /etc /backup/initial/etc

############################## BACKUP /home
cp -r /home /backup/initial/home

############################## BACKUP /bin
cp -r /bin /backup/initial/bin

############################## BACKUP /usr/bin
cp -r /usr/bin /backup/initial/usr/bin


################################## INSTALL SNOOPY
echo "Installing Snoopy Logger..."
wget -O install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh &&
chmod 755 install-snoopy.sh &&
sudo ./install-snoopy.sh stable

# UFW Configuration Section
echo "Setting up UFW..."
# Disable UFW immediately after confirming its installation for configuration
echo "Disabling UFW temporarily for configuration..."
sudo ufw disable

## First, reset default rules
sudo ufw --force reset

## Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

## Loop through allowPorts array to allow each port
for port in "${allowPorts[@]}"; do
    echo "Allowing port $port through UFW..."
    sudo ufw allow "$port"
done

# Enable UFW
sudo ufw --force enable
echo "UFW has been configured and re-enabled."

# Check the status
sudo ufw status verbose
