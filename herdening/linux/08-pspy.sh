#!/bin/bash

wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
chmod +x pspy64
./pspy64 | grep -vE "grep -qE|grep -qx|grep -qw|bash 8-pkillBash.sh|bash 4-ensureCorrectUsers.sh centos|grep -E (nc|netcat|bash|sh|zsh|mkfifo|python|perl|ruby|wget|curl)"