#!/bin/bash

# Script to Deny Anonymous Logins for SMB and FTP

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# For Samba (SMB)
echo "Configuring Samba (SMB) to deny anonymous logins..."
if [ -f /etc/samba/smb.conf ]; then
    cp /etc/samba/smb.conf /etc/samba/smb.conf.backup
    sed -i '/^\[global\]/a \
    map to guest = never' /etc/samba/smb.conf
    systemctl restart smbd
else
    echo "Samba (smb.conf) not found. Skipping SMB configuration."
fi

# For vsftpd (FTP)
echo "Configuring vsftpd to deny anonymous logins..."
if [ -f /etc/vsftpd.conf ]; then
    cp /etc/vsftpd.conf /etc/vsftpd.conf.backup
    sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' /etc/vsftpd.conf
    systemctl restart vsftpd
else
    echo "vsftpd.conf not found. Skipping FTP configuration."
fi

echo "Configuration changes complete."
