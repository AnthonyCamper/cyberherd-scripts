# Ensure the script is run with Administrator privileges
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Please run PowerShell as an Administrator."
    Break
}

# Backup DNS Configuration
Export-Clixml -Path "C:\Backup\DNSConfigBackup.xml" -InputObject (Get-DnsServerZone)

# Restore DNS Configuration
# Import-Clixml -Path "C:\Backup\DNSConfigBackup.xml" | ForEach-Object { Set-DnsServerZone $_ }

# Mitigate LLMNR Poisoning
# This setting is not directly available via PowerShell for all Windows versions, often managed via Group Policy:
# Computer Configuration -> Administrative Templates -> Network -> DNS Client -> Turn off Multicast Name Resolution
# Set the policy to Enabled to mitigate LLMNR Poisoning

# Disable IPv6
# This action is impactful and should be carefully considered before implementation
# Disable IPv6 on all nontunnel interfaces (not recommended without thorough testing)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" -Name "DisabledComponents" -Value 0xFF
