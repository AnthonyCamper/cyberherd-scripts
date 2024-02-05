# replace IP with bad actor's ip.
#!/bin/bash

echo -n "Enter IP Address:"
read ip
sudo iptables -A INPUT -s $ip -j DROP