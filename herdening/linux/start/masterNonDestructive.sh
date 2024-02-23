#!/bin/bash

##################################### IMPORTANT
##################################### IMPORTANT
##################################### IMPORTANT

##################################### Update these values
# update desired users, this is a list of users with login shells that we want to keep (no rbash, no changes)
predefined_users=(
seccdc_black
postgres
root
)

# Define the array of desired ports
desiredPorts=(8080 443 80 22)

# exclude these users from rbash (ie make every user that isn't these and has a login shell rbash)
noRBash=("seccdc_black" "jack.rover" "root") # Add more usernames as needed


# old init.sh
# Setup by installing required programs like dependencies, git, fail2ban, and ufw, configure what is nessesary, and do some basic hardening.
# Usage bash 1setupInstallHarde.sh <port1> <port2> (bash 1setupInstallHarde.sh 22 80 443 8080)
if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1
fi

echo "Ports to be allowed through UFW:"
for port in "${desiredPorts[@]}"; do
    echo "- $port"
done


read -r -p "Do you want to proceed with the above ports? (y/n): " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Proceeding with the setup..."
else
    echo "Aborting."
    exit 0
fi


id_like_line=$(grep '^ID=' /etc/os-release)

operatingSystem=$(echo $id_like_line | cut -d'=' -f2 | tr -d '"')

if [ -z "$operatingSystem" ]; then
    echo "The ID_LIKE line was not found or is empty."
else
    echo "Operating System base: $operatingSystem"
fi

if [ "$operatingSystem" = "debian" ] || [ "$operatingSystem" = "ubuntu" ]; then
    echo "$operatingSystem detected, using apt"

    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install rsyslog -y
    sudo apt install git -y
    sudo apt install socat -y
    sudo apt install fail2ban -y
    sudo apt install zip -y
    sudo apt install net-tools -y
    sudo apt install htop -y
    sudo apt install e2fsprogs -y
    sudo apt purge cron -y
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban

    sudo apt install ufw -y

elif [ "$operatingSystem" = "centos" ]; then
    echo "CentOS detected, using yum"
    sudo dnf update -y
    sudo yum update -y
    sudo yum install -y epel-release
    sudo yum install git -y
    sudo yum install socat -y
    sudo yum install fail2ban -y
    sudo yum install zip -y
    sudo yum install net-tools -y
    sudo yum install htop -y
    sudo yum install e2fsprogs -y #this installs chattr
    sudo yum remove cron -y
    sudo systemctl enable fail2ban
    sudo systemctl start fail2ban

    sudo yum install ufw -y
fi

############################## BACKUPS
echo "Creating backups..."
sudo mkdir -p /backup/initial

############################## BACKUP /etc
cp -r /etc /backup/initial/etc

############################## BACKUP /var/www
cp -r /var/www /backup/initial/etc

############################## BACKUP /home
cp -r /home /backup/initial/home

############################## BACKUP /bin
cp -r /bin /backup/initial/bin

############################## BACKUP /usr/bin
cp -r /usr/bin /backup/initial/usr/bin

echo "Setting up UFW..."
echo "Disabling UFW temporarily for configuration..."
sudo ufw disable

sudo ufw --force reset

sudo ufw default deny incoming
sudo ufw default allow outgoing



# Loop through the array
for port in "${desiredPorts[@]}"; do
    echo "Allowing port $port through UFW..."
    sudo ufw allow "$port"
done

sudo ufw --force enable
echo "UFW has been configured and re-enabled."

sudo ufw status verbose

# Goal of this script is to find users that are unauthorized, with a login shell.
valid_shells=(/bin/bash /bin/sh /usr/bin/zsh /usr/bin/fish)



while IFS=: read -r username _ _ _ _ _ shell; do
    for valid_shell in "${valid_shells[@]}"; do
        if [[ "$shell" == "$valid_shell" ]]; then
            if ! printf '%s\n' "${predefined_users[@]}" | grep -qx "$username"; then
                echo "User '$username' is NOT in the predefined list but has a valid shell: $shell"
                userdel -r $username || deluser $username --remove-home
            fi
            break
        fi
    done
done < /etc/passwd



# Function to check if a user is in the noRBash array
is_in_noRBash() {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}

# New .bashrc content
new_bashrc_content="# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi"

while IFS=: read -r username _ _ _ _ home shell; do
    if [ ! -d "$home" ] || [ "$username" = "seccdc_black" ]; then
        # Skip if home directory doesn't exist or the user is seccdc_black
        continue
    fi

    if ! is_in_noRBash "$username" "${noRBash[@]}"; then
        if grep -q "$shell" /etc/shells; then
            # The user's shell is valid, change to rbash if not already rbash
            if [ "$shell" != "/bin/rbash" ]; then
                sudo usermod -s /bin/rbash "$username"
            fi
        fi
    fi

    # Overwrite .bashrc, disable history, make immutable, and adjust ownership
    if [ -f "$home/.bashrc" ]; then
        echo "$new_bashrc_content" > "$home/.bashrc"
        echo 'HISTFILE=/dev/null' >> "$home/.bashrc"
        echo 'unset HISTFILE' >> "$home/.bashrc"
        sudo chattr +i "$home/.bashrc"
    fi

    if [ -f "$home/.zshrc" ]; then
        echo 'HISTFILE=/dev/null' >> "$home/.zshrc"
        echo 'unset HISTFILE' >> "$home/.zshrc"
        sudo chattr +i "$home/.zshrc"
    fi

    [ -f "$home/.bashrc" ] && chown "$username" "$home/.bashrc"
    [ -f "$home/.zshrc" ] && chown "$username" "$home/.zshrc"

done < /etc/passwd

# run weem nixarmor
sudo bash ../oh-brother/init.sh

# Chattr important config files (2nd to last)
sudo chattr -i /etc/ssh/sshd_config

# Harden SSH
if service sshd status > /dev/null; then
	# We're using root over SSH, so we enable it
	sed -i '1s;^;PermitRootLogin yes\n;' /etc/ssh/sshd_config
	sed -i '1s;^;PubkeyAuthentication no\n;' /etc/ssh/sshd_config

	# Don't set UsePAM no for Fedora, RHEL, CentOS
	if ! cat /etc/os-release | grep -q "REDHAT_"; then
		sed -i '1s;^;UsePAM no\n;' /etc/ssh/sshd_config
	fi

	sed -i '1s;^;UseDNS no\n;' /etc/ssh/sshd_config
	sed -i '1s;^;PermitEmptyPasswords no\n;' /etc/ssh/sshd_config
	sed -i '1s;^;AddressFamily inet\n;' /etc/ssh/sshd_config

	# Restart service if config is good
	sshd -t && systemctl restart sshd
fi

# (last)
# rename and symlink relevant binaries (rm, chattr)
# mv `which chattr` /usr/bin/shhh # this is done by users 1
sudo `which rm` /usr/bin/bruh

