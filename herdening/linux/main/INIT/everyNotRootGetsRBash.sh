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

while IFS=: read -r username _ _ _ _ home shell; do
  if containsElement "$shell" "${valid_shells[@]}" && ! containsElement "$username" "${excludeFromRBash[@]}"; then
    echo "Changing shell for $username to rbash..."
    chsh -s /bin/rbash "$username"
    
    # Ensure the home directory and .shrc files are owned by the user
    chown -R "$username":"$username" "$home"
    chown "$username":"$username" "$home"/.*shrc 2>/dev/null
    
    # Clear and reset environment variables in .shrc files
    echo 'HISTFILE=/dev/null' > "$home"/.*shrc
    echo 'unset HISTFILE' >> "$home"/.*shrc
    echo 'PATH=/usr/local/rbin' >> "$home"/.*shrc # Change to a safe, restricted bin directory
    echo 'export PATH' >> "$home"/.*shrc
    
    # Create a restricted bin directory if it doesn't exist and populate it with allowed commands
    mkdir -p /usr/local/rbin
    chown root:root /usr/local/rbin
    chmod 755 /usr/local/rbin
    # Link necessary commands here, e.g., ln -s /bin/ls /usr/local/rbin/ls
    ln -s /usr/bin/whoami /usr/local/rbin/whoami
    ln -s /usr/bin/id /usr/local/rbin/id

    # Ensure the symbolic links are owned by root and not writable by others
    chown root:root /usr/local/rbin/whoami
    chown root:root /usr/local/rbin/id
    chmod 755 /usr/local/rbin/whoami
    chmod 755 /usr/local/rbin/id
    
    if command -v apk >/dev/null; then
        echo 'export PATH=/usr/local/rbin' >> "$home"/.profile # Ensure PATH is restricted even here
    fi
    
    # Make .shrc files immutable to prevent changes
    sudo chattr +i "$home"/.*shrc 2>/dev/null
    
    # Ensure users cannot execute files from their home directory
    chmod -R go-w "$home"
    find "$home" -type d -exec chmod go+x {} +  # Allow directory traversal but not execution
  fi
done < /etc/passwd



echo "Shell change process completed."
