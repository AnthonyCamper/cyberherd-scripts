#!/bin/bash

#Creating TextFile
touch "enum_doc.txt"
enum_doc="enum_doc.txt"
echo "Filename $enum_doc created successfully, populating data"

#Reading in Step 1 Variables
machine_name=$(hostname)
echo -e "Machine name: \n$machine_name" >> $enum_doc
ip_addresses=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}...')
echo -e "IP addresses: \n$ip_addresses" >> $enum_doc
mac_addresses=$(ip link | grep "link")
echo -e "MAC adresses: \n$mac_addresses" >> $enum_doc
whoami=$(whoami) 
echo -e "WhoAMI return: \n$whoami">> $enum_doc
current_date=$(date) >> $enum_doc
echo -e "Current DateTime: \n$current_date" >> $enum_doc
