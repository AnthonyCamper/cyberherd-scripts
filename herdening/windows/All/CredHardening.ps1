# Ensure the script is run with Administrator privileges
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Please run PowerShell as an Administrator."
    Break
}

# Check for and remove GPP passwords in SYSVOL
# Note: This example provides a path to search. Replace "YourDomain" with your actual domain.
$sysvolPath = "\\YourDomain\SYSVOL\YourDomain\Policies"
Get-ChildItem -Path $sysvolPath -Recurse -Filter "*.xml" | ForEach-Object {
    $content = Get-Content $_.FullName
    if ($content -match "<cpassword>")
    {
        Write-Host "Found GPP password in file: $($_.FullName)"
        # Remove or secure the file appropriately
    }
}

# Enable LSA protections
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RunAsPPL" -Value 1 -PropertyType "DWord"

# Disable WDigest
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest" -Name "UseLogonCredential" -Value 0

# Disable the debug right for local administrators
# This requires setting a User Right Assignment via GPO: "Deny access to this computer from the network"
# Manual action required in Group Policy Management Console (GPMC)

# Disable storage of plain text passwords in AD via GPO
# This requires configuring the GPO: "Network security: Do not store LAN Manager hash value on next password change"
# Manual action required in Group Policy Management Console (GPMC)

# Disable password caching
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "CachedLogonsCount" -Value 0

# Enable Credential Guard
# This often requires hardware support and BIOS settings along with GPO settings.
# Use Device Guard and Credential Guard hardware readiness tool to check and enable

# Remove GPP password (covered above)

# Disable cached creds in CredSSP
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Credssp\Parameters" -Name "AllowDelegatingSavedCredentials" -Value 0

# Disable reversible encryption
# This setting is managed via AD: "User Account Properties" -> "Account" tab -> "Store password using reversible encryption"
# PowerShell command to set this on a per-user basis, adjust for batch processing:
# Set-ADUser -Identity "UserName" -PasswordNeverExpires $false -PasswordNotRequired $false -CannotChangePassword $false -ReversibleEncryptionEnabled $false

Write-Host "Hardening tasks completed. Please review any manual steps required."