#!/bin/bash

# The Goal of this script is to check common directories for common reverse shells.
echo "########################################## Checking HOME DIRECTORIES #################################################"
grep -RIlP '(/dev/(tcp|udp)/.+|nc(\.exe)? -e sh|mkfifo /tmp/|exec [0-9]<>|perl -e|php -r|python(3)? -c|ruby -rsocket|socat|sqlite3 /dev/null|\$\(mktemp -u\)|zsh -c|lua(5\.1)? -e|go run|v run|awk \'BEGIN').*\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' /home 2>/dev/null
echo "########################################## Checking SERVICES DIRECTORIES #################################################"
grep -RIlP '(/dev/(tcp|udp)/.+|nc(\.exe)? -e sh|mkfifo /tmp/|exec [0-9]<>|perl -e|php -r|python(3)? -c|ruby -rsocket|socat|sqlite3 /dev/null|\$\(mktemp -u\)|zsh -c|lua(5\.1)? -e|go run|v run|awk \'BEGIN').*\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' /etc/systemd/ 2>/dev/null
echo "########################################## Checking /var/www DIRECTORIES #################################################"
grep -RIlP '(/dev/(tcp|udp)/.+|nc(\.exe)? -e sh|mkfifo /tmp/|exec [0-9]<>|perl -e|php -r|python(3)? -c|ruby -rsocket|socat|sqlite3 /dev/null|\$\(mktemp -u\)|zsh -c|lua(5\.1)? -e|go run|v run|awk \'BEGIN').*\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' /var/www 2>/dev/null
echo "########################################## Checking /root DIRECTORIES #################################################"
grep -RIlP '(/dev/(tcp|udp)/.+|nc(\.exe)? -e sh|mkfifo /tmp/|exec [0-9]<>|perl -e|php -r|python(3)? -c|ruby -rsocket|socat|sqlite3 /dev/null|\$\(mktemp -u\)|zsh -c|lua(5\.1)? -e|go run|v run|awk \'BEGIN').*\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' /root 2>/dev/null
echo "########################################## Checking /etc DIRECTORIES #################################################"
grep -RIlP '(/dev/(tcp|udp)/.+|nc(\.exe)? -e sh|mkfifo /tmp/|exec [0-9]<>|perl -e|php -r|python(3)? -c|ruby -rsocket|socat|sqlite3 /dev/null|\$\(mktemp -u\)|zsh -c|lua(5\.1)? -e|go run|v run|awk \'BEGIN').*\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' /etc 2>/dev/null