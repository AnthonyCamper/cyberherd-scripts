#!/bin/bash

sudo ufw disable
# Define the array of ports to open
open_ports=(80 443 22 3306 21 20) # Add your desired ports here

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Loop through the open_ports array and allow each port
for port in "${open_ports[@]}"; do
    sudo ufw allow $port
done

# Enable UFW
sudo ufw enable

sudo ufw restart

# Check the status of UFW
sudo ufw status verbose
