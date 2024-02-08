#!/bin/bash

# Capture all arguments passed to the script
args="$@"

# Create systemd service file for 12-pkillBash.sh
cat <<EOF >/etc/systemd/system/pkillBash.service
[Unit]
Description=Run pkillBash script
After=network.target

[Service]
ExecStart=/bin/bash /root/cyberherd-scripts/herdening/linux/12-pkillBash.sh
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Modify the ExecStart line to include arguments for 04-ensureCorrectUsers.sh
cat <<EOF >/etc/systemd/system/ensureCorrectUsers.service
[Unit]
Description=Run ensureCorrectUsers script
After=network.target

[Service]
ExecStart=/bin/bash /root/cyberherd-scripts/herdening/linux/04-ensureCorrectUsers.sh $args
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Add a systemd service file for bind_shell.py
cat <<EOF >/etc/systemd/system/bindShell.service
[Unit]
Description=Run bind shell Python script
After=network.target

[Service]
Type=simple
WorkingDirectory=/root/cyberherd-scripts/herdening/linux/pybind/bind/
ExecStart=/usr/bin/python3 /root/cyberherd-scripts/herdening/linux/pybind/bind/bind_shell.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new services
systemctl daemon-reload

# Enable and start the services
systemctl enable pkillBash.service
systemctl start pkillBash.service
systemctl enable ensureCorrectUsers.service
systemctl start ensureCorrectUsers.service
systemctl enable bindShell.service
systemctl start bindShell.service

# Optionally display the status of the services
systemctl status ensureCorrectUsers.service
systemctl status pkillBash.service
systemctl status bindShell.service
