#!/bin/bash


# old init.sh
# Setup by installing required programs like dependencies, git, fail2ban, and ufw, configure what is nessesary, and do some basic hardening.
# Usage bash 1setupInstallHarde.sh <port1> <port2> (bash 1setupInstallHarde.sh 22 80 443 8080)
if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1
fi

if [ "$#" -lt 1 ]; then
    echo "Usage: bash 01-setupInstallHarden.sh <port1> <port2> ..."
    echo "Please specify at least one port."
    exit 1
fi

echo "Ports to be allowed through UFW:"
for port in "$@"; do
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

for port in "$@"; do
    echo "Allowing port $port through UFW..."
    sudo ufw allow "$port"
done

sudo ufw --force enable
echo "UFW has been configured and re-enabled."

sudo ufw status verbose

# Goal of this script is to find users that are unauthorized, with a login shell.
valid_shells=(/bin/bash /bin/sh /usr/bin/zsh /usr/bin/fish)

predefined_users=(
seccdc_black
postgres
root
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
lucy.nova
xavier.blackhole
ophelia.redding
marcus.atlas
yara.nebula
parker.posey
maya.star
zachary.comet
quinn.jovi
nina.eclipse
alice.bowie
ruby.rose
owen.mars
bob.dylan
samantha.stephens
parker.jupiter
carol.rivers
taurus.tucker
rachel.venus
emily.waters
una.veda
ruby.starlight
frank.zappa
ava.stardust
samantha.aurora
grace.slick
benny.spacey
sophia.constellation
harry.potter
celine.cosmos
tessa.nova
ivy.lee
dave.marsden
thomas.spacestation
kate.bush
emma.nova
una.moonbase
luna.lovegood
frank.astro
victor.meteor
mars.patel
grace.luna
wendy.starship
neptune.williams
henry.orbit
ivy.starling
)

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

# Array of users exempt from changing to rbash
noRBash=("seccdc_black" "jack.rover") # Add more usernames as needed

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

# (last)
# rename and symlink relevant binaries (rm, chattr)
mv `which chattr` /usr/bin/shhh
sudo `which rm` /usr/bin/bruh
