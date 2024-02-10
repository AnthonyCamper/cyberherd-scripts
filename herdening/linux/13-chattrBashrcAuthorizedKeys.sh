#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

# Iterate over each user's home directory
while IFS=: read -r username _ _ _ _ homedir _; do
  # Skip if user does not have a home directory, the directory does not exist, or the user is seccdc_black
  if [ -z "$homedir" ] || [ ! -d "$homedir" ] || [ "$username" == "seccdc_black" ]; then
    continue
  fi

  # Path to the user's authorized_keys file
  authorized_keys_file="$homedir/.ssh/authorized_keys"

  # Check if the authorized_keys file exists
  if [ -f "$authorized_keys_file" ]; then
    # Empty the authorized_keys file
    echo -n > "$authorized_keys_file"

    # Make the authorized_keys file immutable
    chattr +i "$authorized_keys_file"
    echo "authorized_keys for $username made empty and immutable."
  fi

done < /etc/passwd

echo "All applicable authorized_keys files have been processed."
