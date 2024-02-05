Import-Module ActiveDirectory

$newPassword = "NewSecurePassword123!"

$securePassword = ConvertTo-SecureString -AsPlainText $newPassword -Force

$users = Get-ADUser -Filter 'Enabled -eq $true' # This example filters to enabled accounts where the password does not never expire.

foreach ($user in $users) {
    try {
        Set-ADAccountPassword -Identity $user.DistinguishedName -NewPassword $securePassword -Reset -Confirm:$false
        Write-Host "Password changed for $($user.SamAccountName)"
    } catch {
        Write-Host "Failed to change password for $($user.SamAccountName): $_"
    }
}

Write-Host "Completed changing passwords for all domain users."
