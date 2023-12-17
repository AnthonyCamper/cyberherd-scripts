#!/bin/bash

# Function to detect the OS and version
detect_os_and_version() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        echo "Unable to detect operating system."
        exit 1
    fi
}

# Function to install Snoopy
install_snoopy() {
    wget -O install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh
    chmod 755 install-snoopy.sh
    sudo ./install-snoopy.sh stable
}

# Function to create and enable systemd service
create_and_enable_service() {
    cat <<EOF | sudo tee /etc/systemd/system/snoopy.service
[Unit]
Description=Snoopy Logger

[Service]
ExecStart=/usr/local/bin/snoopy

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable snoopy
    sudo systemctl start snoopy
}

# Function to guess Snoopy log file location
guess_snoopy_log_location() {
    case "$OS" in
        "Ubuntu"|"Debian")
            echo "/var/log/auth.log"
            ;;
        "CentOS")
            echo "/var/log/secure"
            ;;
        *)
            echo "Log location might be /var/log/messages, but check your syslog configuration to be sure."
            ;;
    esac
}

# Detect OS
detect_os_and_version

# Install Snoopy
install_snoopy

# Create and enable systemd service
create_and_enable_service

# Guess log file location
LOG_LOCATION=$(guess_snoopy_log_location)

echo "Snoopy installation and configuration complete on $OS $VER."
echo "Snoopy logs are likely to be found in $LOG_LOCATION."
