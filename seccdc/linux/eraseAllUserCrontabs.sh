#!/bin/bash

sudo bash -c 'for user in $(cut -d: -f1 /etc/passwd); do crontab -r -u $user 2>/dev/null; done'