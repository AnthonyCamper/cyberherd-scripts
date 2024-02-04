#!/bin/bash

if [ $(whoami) != "root" ]; then
    echo "Script must be run as root"
    exit 1
fi

# Definitions

###################################################### SCORECHECK USER #################################################
DONOTTOUCH=(
seccdc_black
)
###################################################### SCORECHECK USER #################################################

###################################################### ADMINS #################################################
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

echo "List of administrators:"
for admin in "${administratorGroup[@]}"; do
echo "$admin"
done

##################################################### PIPING BASH HISTORY TO /DEV/NULL ###############################
# Redirect the content of .bash_history to /dev/null
cat /dev/null > ~/.bash_history

# Optional: Clear the in-memory history for the current session
history -c

###################################################### NORMAL USERS #################################################
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
frank.zappa
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


############################## ADDING AND REMOVING ADMINISTRATORS


# Loop through the array and add each user to the administrator group, to ensure that is setup correctly
for user in "${administratorGroup[@]}"; do
  usermod -aG administrator "$user"
done

# Loop through the array and remove each user from the administrator group if they are a part of it
for user in "${normalUsers[@]}"; do
  # Check if the user is in the administrator group
  if id "$user" | grep -q 'administrator'; then
    # User is in the administrator group, remove them
    gpasswd -d "$user" administrator
    echo "Removed $user from the administrator group."
  else
    echo "$user is not in the administrator group."
  fi
done

# General Best Practices


################################## INSTALL SNOOPY
wget -O install-snoopy.sh https://github.com/a2o/snoopy/raw/install/install/install-snoopy.sh &&
chmod 755 install-snoopy.sh &&
sudo ./install-snoopy.sh stable

##################################### CORRECT PERMS ON /ETC/PASSWD, /ETC/SHADOW, /ETC/GROUP, AND /ETC/GSHADOW

chmod 644 /etc/passwd
chown root:root /etc/passwd

chmod 600 /etc/shadow
chown root:root /etc/shadow

chmod 644 /etc/group
chown root:root /etc/group

chmod 600 /etc/gshadow
chown root:root /etc/gshadow

# Handling OS-SpecificThings

# Read the ID  line from /etc/os-release
id_like_line=$(grep '^ID=' /etc/os-release)

# Extract the value after the equals sign, removing potential quotes
operatingSystem=$(echo $id_like_line | cut -d'=' -f2 | tr -d '"')

# spread looks like this: "debian" covers debian and ajacent + ubuntu distros

####################################################
##################   DEBIAN & UBUNTU   ############################
####################################################



# Check if operatingSystem is empty
if [ -z "$operatingSystem" ]; then
    echo "The ID_LIKE line was not found or is empty."
else
    echo "Operating System base: $operatingSystem"
fi

if [ "$operatingSystem" = "debian" ]; then
    echo "Debian detected, use apt"

    # Get the system up to date
    sudo apt update -y
    sudo apt upgrade -y

# Install Git
    sudo apt install git -y
		
	# Install socat for snoopy
	sudo apt install socat -y
    # Install and enable fail2ban
    sudo apt install fail2ban -y
    sudo enable fail2ban 

    # Install UFW
    apt install ufw -y
fi

if [ "$operatingSystem" = "ubuntu" ]; then
    echo "Debian detected, use apt"

    # Get the system up to date
    sudo apt update -y
    sudo apt upgrade -y
		
	# Install socat for snoopy
	sudo apt install socat -y
    # Install and enable fail2ban
    sudo apt install fail2ban -y
    sudo enable fail2ban 

    # Install UFW
   sudo apt install ufw -y
fi
if [ "$operatingSystem" = "centos" ]; then
    echo "CentOS detected, use yum"

    # Get the system up to date
    sudo dnf update -y
    sudo yum update -y

# Install git
sudo yum install git -y
		
	# Install socat for snoopy
	sudo yum install socat -y
    # Install and enable fail2ban
    sudo yum install fail2ban -y
    sudo enable fail2ban 

    # Install UFW
    yum install ufw -y
fi
    # Setup UFW
    ## First, reset default rules
    ufw --force reset

    ## Set default policies
    ufw default deny incoming
    ufw default allow outgoing

    ## Allow specific ports
    ufw allow 21    # FTP
    ufw allow 22    # SSH
    ufw allow 53    # DNS
    ufw allow 3306  # MySQL
    ufw allow 80    # HTTP

    # Enable UFW
    ufw --force enable

    # Check the status
    ufw status verbose
  


############################## BACKUPS
sudo mkdir /backup
mkdir /backup/initial

############################## BACKUP /etc

cp -r /etc /backup/initial/etc

############################## BACKUP /home

cp -r /home /backup/initial/home