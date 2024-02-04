#!/usr/bin/env bash


# REMOVING
# UNAUTHORIZED
# USERS

# Define the list of users to keep
KEEP_USERS=(
    "root"
    "daemon"
    "bin"
    "sys"
    "sync"
    "games"
    "man"
    "lp"
    "mail"
    "news"
    "uucp"
    "proxy"
    "www-data"
    "backup"
    "list"
    "irc"
    "gnats"
    "nobody"
    "systemd-network"
    "systemd-resolve"
    "messagebus"
    "systemd-timesync"
    "syslog"
    "_apt"
    "tss"
    "uuidd"
    "systemd-oom"
    "tcpdump"
    "avahi-autoipd"
    "usbmux"
    "dnsmasq"
    "kernoops"
    "avahi"
    "cups-pk-helper"
    "rtkit"
    "whoopsie"
    "sssd"
    "speech-dispatcher"
    "fwupd-refresh"
    "nm-openvpn"
    "saned"
    "colord"
    "geoclue"
    "pulse"
    "gnome-initial-setup"
    "hplip"
    "gdm"
    "mandate"
)
# Function to check if a user is in the KEEP_USERS array
is_user_in_keep_list() {
    local user=$1
    for keep_user in "${KEEP_USERS[@]}"; do
        if [[ $user == $keep_user ]]; then
            return 0
        fi
    done
    return 1
}

# Get the list of all users
ALL_USERS=$(cut -d: -f1 /etc/passwd)

for user in $ALL_USERS; do
    # Check if the user is in the keep list
    if ! is_user_in_keep_list "$user"; then
        # Remove the user if not in the keep list
        # Warning: This will delete the user and their home directory!
        userdel -r "$user"
        echo "Removed user $user"
    else
        echo "Kept user $user"
    fi
done
