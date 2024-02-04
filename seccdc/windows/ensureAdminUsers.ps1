# List of users who should have administrative access
$usersWithAdminAccess = @(
    'elara.boss', 'sarah.lee', 'lisa.brown',
    'michael.davis', 'emily.chen', 'tom.harris',
    'bob.johnson', 'david.kim', 'rachel.patel',
    'dave.grohl', 'kate.skye', 'leo.zenith',
    'jack.rover'
)

# Get the current members of the Administrators group
$adminGroupMembers = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name

foreach ($user in $usersWithAdminAccess) {
    # Check if the user already has administrative access
    $userFullName = "localhost\$user"
    if ($adminGroupMembers -contains $userFullName) {
        Write-Output "User $user already has administrative access."
    } else {
        try {
            # Attempt to add the user to the Administrators group
            Add-LocalGroupMember -Group "Administrators" -Member $user
            Write-Output "User $user has been granted administrative access."
        } catch {
            Write-Error "Failed to add $user to Administrators group. Error: $_"
        }
    }
}
