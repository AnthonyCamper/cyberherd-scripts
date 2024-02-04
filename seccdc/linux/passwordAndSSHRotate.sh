#!/bin/bash

# Define the user to exclude from logging
excludeUser="seccdc_black"

# Administrator group array (example names, replace with actual usernames)
administratorGroup=(
elara.boss
sarah.lee
lisa.brown
michael.davis
emily.chen
tom.harris
bob.johnson
david.kim
rachel.patel
dave.grohl
kate.skye
leo.zenith
jack.rover
root
)

# Function to check if a user is in the administratorGroup
userIsAdmin() {
    local e
    for e in "${administratorGroup[@]}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

# Generate the output file name based on the hostname
hostname=$(hostname)
outputFile="/TEAM34_${hostname}_SSH_PASSWD.csv"

# Create directory for the shared SSH keys if it doesn't exist
keyDir="/etc/ssh/shared_keys"
mkdir -p "$keyDir"

# Generate a single SSH key pair for all users, if not already exists
sshKey="$keyDir/shared_key"
if [ ! -f "$sshKey" ]; then
    ssh-keygen -t rsa -b 4096 -f "$sshKey" -N ''
    echo "Shared SSH key pair generated."
else
    echo "Shared SSH key pair already exists."
fi

# Prompt for the passphrase
echo "Enter the new passphrase for all users (except for logging $excludeUser):"
read -s sharedPassphrase

# Check if passphrase is empty
if [[ -z "$sharedPassphrase" ]]; then
    echo "Passphrase cannot be empty. Exiting..."
    exit 1
fi

# Check if the outputFile exists, create if not
if [ ! -f "$outputFile" ]; then
    touch "$outputFile"
    echo "Output file created at $outputFile"
fi

# Iterate over all users, excluding the specified user from logging
getent passwd | while IFS=: read -r username password uid gid full home shell; do
    # Change password for all users except seccdc_black
    if [[ "$username" != "$excludeUser" ]]; then
        echo "$username:$sharedPassphrase" | chpasswd
        if [ $? -eq 0 ]; then
            echo "Password changed for $username"
            # Log to the output file except for administratorGroup users
            if ! userIsAdmin "$username"; then
                echo "HOSTNAME-SERVICE,$username,$sharedPassphrase" >> "$outputFile"
            fi
        else
            echo "Failed to change password for $username"
            continue
        fi
    # Set the shared SSH key pair for each user and overwrite the authorized_keys file
    if [ "$username" == "root" ]; then
        userSshDir="/root/.ssh"
    else
        userSshDir="/home/$username/.ssh"
    fi
    mkdir -p "$userSshDir"
    chmod 700 "$userSshDir"
    chown -R "$username":"$gid" "$userSshDir" # Use -R to recursively change ownership and permissions
    cp "$sshKey" "$userSshDir/id_rsa"
    cp "$sshKey.pub" "$userSshDir/id_rsa.pub"
    # Overwrite the authorized_keys file with the public key
    cat "$sshKey.pub" > "$userSshDir/authorized_keys"
    chown -R "$username":"$gid" "$userSshDir" # Use -R to recursively change ownership
    chmod 600 "$userSshDir/id_rsa"
    chmod 644 "$userSshDir/id_rsa.pub" "$userSshDir/authorized_keys"
    echo "Shared SSH keys set for $username."

    fi
done

echo "Script completed. User details, except for administratorGroup, written to $outputFile."