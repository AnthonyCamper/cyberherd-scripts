#!/bin/bash

# Function to apply chattr to a file
apply_chattr() {
    file=$1
    chattr +i "$file"
    if [ $? -eq 0 ]; then
        echo "chattr applied successfully to $file"
    else
        echo "Error applying chattr to $file"
    fi
}

while true; do
    # Get list of all user directories under /home
    user_directories=$(ls -l /home | grep '^d' | awk '{print $9}')

    # Loop through each user directory and apply chattr to .bashrc file
    for user_dir in $user_directories; do
        bashrc_file="/home/$user_dir/.bashrc"
        if [ -f "$bashrc_file" ]; then
            apply_chattr "$bashrc_file"
        else
            echo "File $bashrc_file not found for user $user_dir, skipping..."
        fi
    done

    # Apply chattr to /etc/ssh/sshd_config
    sshd_config="/etc/ssh/sshd_config"
    if [ -f "$sshd_config" ]; then
        apply_chattr "$sshd_config"
    else
        echo "File $sshd_config not found, skipping..."
    fi

    sleep 60
done