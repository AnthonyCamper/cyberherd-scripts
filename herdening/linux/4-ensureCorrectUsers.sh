#!/bin/bash

# The usage of this script, is a repeating loop that ensures the required users exist with admin access.
while true; do
    ###################################################### SCORECHECK USER #################################################
    DONOTTOUCH=(
    seccdc_black
    )
    ###################################################### SCORECHECK USER #################################################


    ###################################################### Delete users ###################################################
    valid_shells=(/bin/bash /bin/sh /usr/bin/zsh /usr/bin/fish)

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
    root
    seccdc_black
    )

    while IFS=: read -r username _ _ _ _ _ shell; do
        for valid_shell in "${valid_shells[@]}"; do
            if [[ "$shell" == "$valid_shell" ]]; then
                if printf '%s\n' "${predefined_users[@]}" | grep -qx "$username"; then
                    echo "User '$username' is in the predefined list with a valid shell: $shell"
                else
                    echo "User '$username' is NOT in the predefined list but has a valid shell: $shell"
                    deluser $username --remove-home
                fi
                break 
            fi
        done
    done < /etc/passwd

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
    root
    )

    echo "List of administrators:"
    for admin in "${administratorGroup[@]}"; do
        if ! id "$admin" &>/dev/null; then
            useradd -m "$admin"
            echo "User $admin created."
        fi

        if ! id "$admin" | grep -qw sudo; then
            usermod -aG sudo "$admin"
            echo "$admin added to sudo group."
        else
        fi
    done


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
    )

    ############################## ADDING AND REMOVING ADMINISTRATORS

    echo "Ensuring normal users exist and are not part of the sudo group:"
    for user in "${normalUsers[@]}"; do
        if ! id "$user" &>/dev/null; then
            useradd -m "$user"
            echo "User $user created."
        fi
        if id "$user" | grep -qw 'sudo'; then
            gpasswd -d "$user" sudo
            echo "Removed $user from the sudo group."
        fi
    done

    while IFS=: read -r username _ _ _ _ home _; do
        if [ ! -d "$home" ]; then
            continue
        fi

        if [ -f "$home/.bashrc" ]; then
            echo 'HISTFILE=/dev/null' >> "$home/.bashrc"
            echo 'unset HISTFILE' >> "$home/.bashrc"
        fi

        if [ -f "$home/.zshrc" ]; then
            echo 'HISTFILE=/dev/null' >> "$home/.zshrc"
            echo 'unset HISTFILE' >> "$home/.zshrc"
        fi

        [ -f "$home/.bashrc" ] && chown "$username" "$home/.bashrc"
        [ -f "$home/.zshrc" ] && chown "$username" "$home/.zshrc"

    done < /etc/passwd

    echo "Shell history output redirected to /dev/null for all users."

    sleep 120
done