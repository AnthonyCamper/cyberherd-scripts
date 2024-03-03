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
    chsh -s /bin/rbash "$username" >/dev/null
    
    chown -R "$username":"$username" "$home"
    chown "$username":"$username" "$home"/.*shrc 2>/dev/null
    
    echo 'HISTFILE=/dev/null' > "$home"/.*shrc
    echo 'unset HISTFILE' >> "$home"/.*shrc
    echo 'PATH=/usr/local/rbin' >> "$home"/.*shrc
    echo 'export PATH' >> "$home"/.*shrc
    
    
    if command -v apk >/dev/null; then
        echo 'export PATH=/usr/local/rbin' >> "$home"/.profile
    fi

    chmod -R go-w "$home"
    find "$home" -type d -exec chmod go+x {} +
    sudo chattr +i "$home"/.*shrc 2>/dev/null
    
  fi
done < /etc/passwd

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


echo "Shell change process completed."
