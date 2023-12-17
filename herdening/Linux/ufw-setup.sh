#! /bin/bash

# Check if the script is ran as root.
# $EUID is a env variable that contains the users UID
# -ne 0 is not equal zero
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Firewall setup

# Verify UFW is installed
sudo apt install ufw
sleep 2
sudo ufw disable

# Setting up default UFW Policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Setting up specific service policies
sudo ufw allow ssh
# sudo ufw allow http
# sudo ufw allow https

# Allowing/denying from specific IP addresses
# sudo ufw allow from IP
# sudo ufw deny from IP
# sudo ufw allow from IP to any port PORT

# Allowing a range of ports
# sudo ufw allow 2000:2004/tcp
# sudo ufw allow 2000:2004/udp

# Deleting UFW rules
# sudo ufw status numbered
# sudo ufw delete NUM

# Enable the UFW service
sudo ufw enable

# Display established policies
sudo ufw status verbose
