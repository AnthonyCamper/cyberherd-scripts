#!/bin/bash

# Script to disable Bash history logging for every user

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Loop through each user's home directory
getent passwd | while IFS=: read -r username _ uid gid _ home shell; do
  # Check if the user's shell is bash
  if [[ "$shell" == */bash ]]; then
    # Only proceed if the home directory exists and is a directory
    if [ -d "$home" ]; then
      bashrc="${home}/.bashrc"
      # Backup the current .bashrc if it exists
      if [ -f "$bashrc" ]; then
        cp "$bashrc" "${bashrc}.backup"
      fi

      # Append configurations to .bashrc to disable history logging
      {
        echo '# Disable Bash history logging'
        echo 'HISTFILE=/dev/null'
        echo 'unset HISTFILE'
      } >> "$bashrc"

      echo "Bash history logging has been disabled for user: $username"
    else
      echo "Home directory for $username does not exist or is not a directory"
    fi
  fi
done

echo "Operation completed for all users with Bash as their login shell."
