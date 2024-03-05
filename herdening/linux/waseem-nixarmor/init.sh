#!/bin/bash

cp fileperms.txt /root/fileperms.txt
## Set SSH Client Alive Count Max to Zero

uname -a | grep -i ubuntu && sudo utils/ubuntu_harden.sh
uname -a | grep -i centos && sudo utils/centos_harden.sh
uname -a | grep -i debian && sudo utils/debian_harden.sh
uname -a | grep -i fedora && sudo utils/fedora_harden.sh
uname -a | grep -i openbsd && sudo utils/openbsd_harden.sh