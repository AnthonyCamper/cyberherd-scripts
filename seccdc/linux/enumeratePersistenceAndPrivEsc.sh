#!/bin/bash

##################### Relatively Expected SUID binaries

expectedSuid=(
  Xorg.wrap
  chage
  check_dhcp
  check_fping
  check_icmp
  check_ide_smart
  chfn
  chrome-sandbox
  chsh
  crontab
  dbus-daemon-launch-helper
  dmcrypt-get-device
  fusermount
  gpasswd
  mount
  mount.cifs
  newgrp
  pam_timestamp_check
  passwd
  pkexec
  polkit-agent-helper-1
  pppd
  snap-confine
  ssh-keysign
  su
  sudo
  umount
  unix_chkpwd
  usernetctl
  vmware-user-suid-wrapper
)

##################### Relatively Expected SGID binaries

expectedSgid=(
  postgresql
  journal
  expiry
  plocate
  write
  dotlockfile
  crontab
  ssh-agent
  wall
  chage
  python2.7
  dist-packages
  site-packages
  fonts
  unix_chkpwd
  cmd
  890a15cc73eb4da7b817acc9d3e80116
  icingaweb2
  modules
  monitoring
  enabledModules
  bash
  netreport
  postdrop
  postqueue
  utempter
  ssh-keysign
)

echo "############################################################## LOOKING FOR SGID"
# Find all setgid files
find / -perm /2000 2>/dev/null | while read sgidBinary; do
  binaryName=$(basename "$sgidBinary")
  if ! [[ " ${expectedSgid[*]} " =~ " ${binaryName} " ]]; then
    # If the binary is not in the expected list, log it to dangerousSGID.txt and print an alert
    echo "ALERT: UNEXPECTED SGID BINARY FOUND: $sgidBinary" | tee -a dangerousSGID.txt
  fi
done

# Find Reverse Shells NOTE: THIS ONLY CHECKS CERTAIN DIRECTORIES 
echo "############################################################## LOOKING FOR /BIN/BASH"
sudo grep -R "/bin/bash" /etc /tmp /dev/shm /home /root --exclude=/etc/passwd --exclude=/etc/shadow

echo "############################################################## LOOKING FOR SUID"
# Repeat the SUID checking process (already present in your script)
find / -perm /4000 2>/dev/null | while read suidBinary; do
  binaryName=$(basename "$suidBinary")
  if ! [[ " ${expectedSuid[*]} " =~ " ${binaryName} " ]]; then
    echo "ALERT: UNEXPECTED SUID BINARY FOUND: $suidBinary" | tee -a dangerousSUID.txt
  fi
done