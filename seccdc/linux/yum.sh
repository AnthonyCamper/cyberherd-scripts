# Definitions

###################################################### SCORECHECK USER #################################################
DONOTTOUCH=(
seccdc_black
)
###################################################### SCORECHECK USER #################################################

###################################################### ADMINS #################################################
administratorGroup=( # these users need to exist
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
root
)

echo "List of administrators:"
for admin in "${administratorGroup[@]}"; do
    # Check if user exists, if not create the user
    if ! id "$admin" &>/dev/null; then
        useradd -m "$admin"
        echo "User $admin created."
    fi
    # Add user to sudo group
    usermod -aG sudo "$admin"
    echo "$admin added to sudo group."
done

##################################################### PIPING BASH HISTORY TO /DEV/NULL ###############################
# Redirect the content of .bash_history to /dev/null we need to do this for /home
cat /dev/null > ~/.bash_history

###################################################### NORMAL USERS #################################################
normalUsers=( #these users need to exist
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
)


############################## ADDING AND REMOVING ADMINISTRATORS


# Loop through the array and add each user to the administrator group, to ensure that is setup correctly
echo "Ensuring normal users exist and are not part of the sudo group:"
for user in "${normalUsers[@]}"; do
    # Check if user exists, if not create the user
    if ! id "$user" &>/dev/null; then
        useradd -m "$user"
        echo "User $user created."
    fi
    # Check if the user is in the sudo group and remove them if necessary
    if id "$user" | grep -qw 'sudo'; then
        gpasswd -d "$user" sudo
        echo "Removed $user from the sudo group."
    else
        echo "$user is not in the sudo group."
    fi
done

while IFS=: read -r username _ _ _ _ home _; do
    # Skip if home directory doesn't exist
    if [ ! -d "$home" ]; then
        continue
    fi

    # Bash: Append to .bashrc to disable history logging
    if [ -f "$home/.bashrc" ]; then
        echo 'HISTFILE=/dev/null' >> "$home/.bashrc"
    fi

    # Zsh: Append to .zshrc to disable history logging
    if [ -f "$home/.zshrc" ]; then
        echo 'HISTFILE=/dev/null' >> "$home/.zshrc"
    fi

    # Ensure the owner of the modified file remains the user
    [ -f "$home/.bashrc" ] && chown "$username" "$home/.bashrc"
    [ -f "$home/.zshrc" ] && chown "$username" "$home/.zshrc"

done < /etc/passwd

echo "Shell history output redirected to /dev/null for all users."
