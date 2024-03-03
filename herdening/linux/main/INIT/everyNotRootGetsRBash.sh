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

while IFS=: read -r username _ _ _ _ _ shell; do
  if containsElement "$shell" "${valid_shells[@]}" && ! containsElement "$username" "${excludeFromRBash[@]}"; then
    echo "Changing shell for $username to rbash..."
    chsh -s /bin/rbash "$username"
    chown "$username" $home/.*shrc
    echo 'HISTFILE=/dev/null' >> $home/.*shrc
    echo 'unset HISTFILE' >> $home/.*shrc
    sudo chattr +i $home/.*shrc
  fi
done < /etc/passwd

echo "Shell change process completed."
