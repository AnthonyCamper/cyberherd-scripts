# Define the array of users to exclude from password rotation
$excludeUsers = @('seccdc_black')

# Get all local users
$localUsers = Get-LocalUser | Where-Object { $_.Enabled -eq $true }

foreach ($user in $localUsers) {
    # Check if the user is not in the exclude list
    if ($user.Name -notin $excludeUsers) {
        # Generate a new password
        $newPassword = "ThisIsASecurePassword123!"
        # Set the new password for the user
        Set-LocalUser -Name $user.Name -Password (ConvertTo-SecureString -AsPlainText $newPassword -Force)

        # Output the changed password user
        Write-Output "Password for user $($user.Name) has been changed."
    } else {
        # Output skipped user
        Write-Output "Skipping user $($user.Name)."
    }
}
