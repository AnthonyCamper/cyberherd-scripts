#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Content to be written to each .bashrc file
bashrc_content="# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
"

# Iterate over each user's home directory
while IFS=: read -r username _ _ _ _ homedir _; do
  # Skip if user does not have a home directory or directory does not exist
  if [ -z "$homedir" ] || [ ! -d "$homedir" ]; then
    continue
  fi

  # Path to the user's .bashrc file
  bashrc_file="$homedir/.bashrc"

  # Write the specified content to the .bashrc file
  echo "$bashrc_content" > "$bashrc_file"

  # Make the .bashrc file immutable
  chattr +i "$bashrc_file"

done < /etc/passwd

echo "All .bashrc files have been updated and made immutable."
