#!/bin/bash

# Define a list of shells considered as valid login shells
valid_shells=(/bin/bash /bin/sh /usr/bin/zsh /usr/bin/fish)

# Predefined list of usernames to compare against
predefined_users=(
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

# Read each line in /etc/passwd
while IFS=: read -r username _ _ _ _ _ shell; do
    for valid_shell in "${valid_shells[@]}"; do
        if [[ "$shell" == "$valid_shell" ]]; then
            # Check if the user with a valid shell is in the predefined list
            if printf '%s\n' "${predefined_users[@]}" | grep -qx "$username"; then
                echo "User '$username' is in the predefined list with a valid shell: $shell"
            else
                echo "User '$username' is NOT in the predefined list but has a valid shell: $shell"
            fi
            break # Break the inner loop once a valid shell or a comparison is made
        fi
    done
done < /etc/passwd

# Check for predefined users who might not have a valid shell
echo "Checking for predefined users without a valid shell..."
for user in "${predefined_users[@]}"; do
    if ! grep -E "^$user:" /etc/passwd | cut -d: -f7 | grep -qwE "$(IFS='|'; echo "${valid_shells[*]}")"; then
        echo "Predefined user '$user' does not have a valid shell or does not exist."
    fi
done
