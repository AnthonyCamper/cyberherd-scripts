# Ensure the Active Directory module is loaded
Import-Module ActiveDirectory

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
"henry.orbit", "ivy.starling"
)

$administratorGroup = @(
"elara.boss", "sarah.lee", "lisa.brown", "michael.davis",
"emily.chen", "tom.harris", "bob.johnson", "david.kim",
"rachel.patel", "dave.grohl", "kate.skye", "leo.zenith",
"jack.rover"
)

$DONOTTOUCH = @(
"seccdc_black"
)

$domainAdminsGroup = "Domain Admins"

# Fetch all existing domain users
$existingUsers = Get-ADUser -Filter * | Select-Object -ExpandProperty SamAccountName

foreach ($user in $normalUsers) {
    if ($DONOTTOUCH -contains $user) { continue }
    if (-not ($existingUsers -contains $user)) {
        New-ADUser -Name $user -SamAccountName $user -UserPrincipalName "$user@yourdomain.com" -Enabled $true
        Write-Host "Created user $user"
    }
    if ((Get-ADGroupMember -Identity $domainAdminsGroup | Select-Object -ExpandProperty SamAccountName) -contains $user) {
        Remove-ADGroupMember -Identity $domainAdminsGroup -Members $user -Confirm:$false
        Write-Host "Removed $user from $domainAdminsGroup"
    }
}

foreach ($admin in $administratorGroup) {
    if ($DONOTTOUCH -contains $admin) { continue }
    if (-not ($existingUsers -contains $admin)) {
        New-ADUser -Name $admin -SamAccountName $admin -UserPrincipalName "$admin@yourdomain.com" -Enabled $true
        Write-Host "Created admin user $admin"
    }
    if (-not ((Get-ADGroupMember -Identity $domainAdminsGroup | Select-Object -ExpandProperty SamAccountName) -contains $admin)) {
        Add-ADGroupMember -Identity $domainAdminsGroup -Members $admin
        Write-Host "Added $admin to $domainAdminsGroup"
    }
}

$allSpecifiedUsers = $normalUsers + $administratorGroup + $DONOTTOUCH
foreach ($existingUser in $existingUsers) {
    if ($allSpecifiedUsers -notcontains $existingUser) {
        Remove-ADUser -Identity $existingUser -Confirm:$false
        Write-Host "User $existingUser is not specified in the lists and was removed."
    }
}

Write-Host "Domain user verification and modification completed."
