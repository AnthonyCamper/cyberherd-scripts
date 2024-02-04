#!/bin/bash

grep -RIlP '(/dev/(tcp|udp)/.+|nc(\.exe)? -e sh|mkfifo /tmp/|exec [0-9]<>|perl -e|php -r|python(3)? -c|ruby -rsocket|socat|sqlite3 /dev/null|\$\(mktemp -u\)|zsh -c|lua(5\.1)? -e|go run|v run|awk \'BEGIN').*\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b' 