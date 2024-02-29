#!/bin/bash

sudo ufw disable

# Define arrays of TCP and UDP ports to open
tcp_ports=(80 443 22 3306 21 20) # Add your desired TCP ports here
udp_ports=(53) # Add your desired UDP ports here

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Loop through the tcp_ports array and allow each TCP port
for port in "${tcp_ports[@]}"; do
    sudo ufw allow $port/tcp
done

# Loop through the udp_ports array and allow each UDP port
for port in "${udp_ports[@]}"; do
    sudo ufw allow $port/udp
done

# Enable UFW
sudo ufw enable

# Restart UFW to apply changes
sudo ufw restart

# Check the status of UFW
sudo ufw status verbose
