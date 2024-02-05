# Define user lists
$normalUsers = @(
"lucy.nova", "xavier.blackhole", "ophelia.redding", "marcus.atlas",
"yara.nebula", "parker.posey", "maya.star", "zachary.comet",
"quinn.jovi", "nina.eclipse", "alice.bowie", "ruby.rose",
"owen.mars", "bob.dylan", "samantha.stephens", "parker.jupiter",
"carol.rivers", "taurus.tucker", "rachel.venus", "emily.waters",
"una.veda", "ruby.starlight", "frank.zappa", "ava.stardust",
"samantha.aurora", "grace.slick", "benny.spacey", "sophia.constellation",
"harry.potter", "celine.cosmos", "tessa.nova", "ivy.lee",
"dave.marsden", "thomas.spacestation", "kate.bush", "emma.nova",
"una.moonbase", "luna.lovegood", "frank.astro", "victor.meteor",
"mars.patel", "grace.luna", "wendy.starship", "neptune.williams",
"henry.orbit", "ivy.starling","WDAGUtilityAccount","Guest", "DefaultAccount"
)

$administratorGroup = @(
"elara.boss", "sarah.lee", "lisa.brown", "michael.davis",
"emily.chen", "tom.harris", "bob.johnson", "david.kim",
"rachel.patel", "dave.grohl", "kate.skye", "leo.zenith",
"jack.rover", "Administrator"
)

$DONOTTOUCH = @(
"seccdc_black"
)

$localAdminGroup = "Administrators"

$existingUsers = Get-LocalUser | Select-Object -ExpandProperty Name

foreach ($user in $normalUsers) {
    if ($DONOTTOUCH -contains $user) { continue }
    if (-not ($existingUsers -contains $user)) {
        New-LocalUser -Name $user -NoPassword -AccountNeverExpires
        Write-Host "Created user $user"
    }
    if ((Get-LocalGroupMember -Group $localAdminGroup -Member $user -ErrorAction SilentlyContinue)) {
        Remove-LocalGroupMember -Group $localAdminGroup -Member $user
        Write-Host "Removed $user from $localAdminGroup"
    }
}

foreach ($admin in $administratorGroup) {
    if ($DONOTTOUCH -contains $admin) { continue }
    if (-not ($existingUsers -contains $admin)) {
        New-LocalUser -Name $admin -NoPassword -AccountNeverExpires
        Write-Host "Created admin user $admin"
    }
    if (-not (Get-LocalGroupMember -Group $localAdminGroup -Member $admin -ErrorAction SilentlyContinue)) {
        Add-LocalGroupMember -Group $localAdminGroup -Member $admin
        Write-Host "Added $admin to $localAdminGroup"
    }
}

$allSpecifiedUsers = $normalUsers + $administratorGroup + $DONOTTOUCH
foreach ($existingUser in $existingUsers) {
    if ($allSpecifiedUsers -notcontains $existingUser) {
        Remove-LocalUser -Name $existingUser
        Write-Host "User $existingUser is not specified in the lists. Consider removing."
    }
}

Write-Host "User verification and modification completed."
