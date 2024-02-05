#!/bin/bash

excludeUser="seccdc_black"

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

userIsAdmin() {
    local e
    for e in "${administratorGroup[@]}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}

hostname=$(hostname)
outputFile="/root/TEAM34_${hostname}_SSH_PASSWD.csv"

keyDir="/etc/ssh/shared_keys"
mkdir -p "$keyDir"

sshKey="$keyDir/shared_key"
if [ ! -f "$sshKey" ]; then
    ssh-keygen -t rsa -b 4096 -f "$sshKey" -N ''
    echo "Shared SSH key pair generated."
else
    echo "Shared SSH key pair already exists."
fi

echo "Enter the new passphrase for all users (except for logging $excludeUser):"
read -s sharedPassphrase

if [[ -z "$sharedPassphrase" ]]; then
    echo "Passphrase cannot be empty. Exiting..."
    exit 1
fi

if [ ! -f "$outputFile" ]; then
    touch "$outputFile"
    echo "Output file created at $outputFile"
fi

getent passwd | while IFS=: read -r username password uid gid full home shell; do
    if [[ "$username" != "$excludeUser" ]]; then
        if [[ "$shell" == *sh ]]; then
            echo "$username:$sharedPassphrase" | chpasswd
            if [ $? -eq 0 ]; then
                echo "Password changed for $username"
                if ! userIsAdmin "$username"; then
                    echo "HOSTNAME-SERVICE,$username,$sharedPassphrase" >> "$outputFile"
                fi
            else
                echo "Failed to change password for $username"
                continue
            fi
            
        userSshDir="$home/.ssh"
        if [[ "$shell" == *sh ]]; then
            mkdir -p $userSshDir
            chmod 700 "$userSshDir"
            chown -R "$username":"$gid" "$userSshDir" 
            cp "$sshKey" "$userSshDir/id_rsa"
            cp "$sshKey.pub" "$userSshDir/id_rsa.pub"
            cat "$sshKey.pub" > "$userSshDir/authorized_keys"
            chown -R "$username":"$gid" "$userSshDir" 
            chmod 600 "$userSshDir/id_rsa"
            chmod 644 "$userSshDir/id_rsa.pub" "$userSshDir/authorized_keys"
            echo "Shared SSH keys set for $username."
        fi
        fi
    fi
done

echo "Script completed. User details, except for administratorGroup, written to $outputFile."