#!/bin/bash

# Array of users to exclude from changing to rbash
excludeFromRBash=("seccdc_black" "root")

# Array of valid login shells
valid_shells=(/bin/bash /bin/sh /usr/bin/zsh /usr/bin/fish)

# Function to check if an item is in an array
containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Iterate over each line in /etc/passwd
while IFS=: read -r username _ _ _ _ _ shell; do
  # Check if the user's shell is one of the valid shells
  if containsElement "$shell" "${valid_shells[@]}" && ! containsElement "$username" "${excludeFromRBash[@]}"; then
    # Change the user's shell to rbash
    echo "Changing shell for $username to rbash..."
    chsh -s /bin/rbash "$username"
  fi
done < /etc/passwd

echo "Shell change process completed."
