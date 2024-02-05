#!/bin/bash

normalUsers=(
lucy.nova
xavier.blackhole
ophelia.redding
marcus.atlas
yara.nebula
parker.posey
maya.star
zachary.comet
quinn.jovi
nina.eclipse
alice.bowie
ruby.rose
owen.mars
bob.dylan
samantha.stephens
parker.jupiter
carol.rivers
taurus.tucker
rachel.venus
emily.waters
una.veda
ruby.starlight
frank.zapp  a
ava.stardust
samantha.aurora
grace.slick
benny.spacey
sophia.constellation
harry.potter
celine.cosmos
tessa.nova
ivy.lee
dave.marsden
thomas.spacestation
kate.bush
emma.nova
una.moonbase
luna.lovegood
frank.astro
victor.meteor
mars.patel
grace.luna
wendy.starship
neptune.williams
henry.orbit
ivy.starling
daemon
bin
sys
sync
games
man
lp
mail
news
uucp
proxy
www-data
backup
list
irc
gnats
nobody
systemd-network
systemd-resolve
systemd-timesync
messagebus
syslog
_apt
tss
uuidd
tcpdump
rtkit
avahi-autoipd
usbmux
dnsmasq
cups-pk-helper
speech-dispatcher
avahi
kernoops
saned
nm-openvpn
hplip
whoopsie
colord
geoclue
pulse
gnome-initial-setup
gdm
sshd
sansforensics
systemd-coredump
clamav
stunnel4
fwupd-refresh
ftp
)

administratorGroup=(
elara.boss
sarah.lee
lisa.brown
michael.davis
emily.chen
tom.harris
bob.johnson
david.kim
rachel.patel
dave.grohl
kate.skye
leo.zenith
jack.rover
sudo
root
adm
syslog
)

DONOTTOUCH=(
seccdc_black
)

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

> context.txt

echo -e "[OS]\n$(cat /etc/os-release)\n" | tee -a context.txt
echo -e "[Hostname]\n$(hostname)\n" | tee -a context.txt
echo -e "[Admins]\n$(for g in adm sudo wheel; do getent group $g; done)\n" | tee -a context.txt
echo -e "[Users]\n$(getent passwd | cut -d':' -f1,7)\n" | tee -a context.txt
echo -e "[IP/MAC]\n$(ip -br -c a || ip a)\n" | tee -a context.txt
echo -e "[Routes]\n$(ip r)\n" | tee -a context.txt
echo -e "[Services]\n$(ss -tulpan)\n" | tee -a context.txt

echo "############# Checking CronTabs in /etc/crontab" 
cat /etc/crontab | tee -a context.txt
echo "############# Checking All Services in /etc/crontab" 
systemctl list-units --type=service --all | tee context.txt


unauthorizedUsers=()
unauthorizedAdmins=()
for user in $(cut -d: -f1 /etc/passwd); do
  if ! containsElement "$user" "${normalUsers[@]}" && ! containsElement "$user" "${administratorGroup[@]}" && ! containsElement "$user" "${DONOTTOUCH[@]}"; then
    unauthorizedUsers+=("$user")
  fi
  if id "$user" | grep -qE 'adm|sudo|wheel' && ! containsElement "$user" "${administratorGroup[@]}"; then
    unauthorizedAdmins+=("$user")
  fi
done

if [ ${#unauthorizedUsers[@]} -ne 0 ]; then
  echo "ALERT: A USER HAS BEEN DETECTED THAT IS NOT AUTHORIZED:" "${unauthorizedUsers[@]}" | tee -a context.txt
fi

if [ ${#unauthorizedAdmins[@]} -ne 0 ]; then
  echo "ALERT: UNAUTHORIZED ADMINISTRATOR DETECTED:" "${unauthorizedAdmins[@]}" | tee -a context.txt
fi

