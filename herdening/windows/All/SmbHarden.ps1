# SMB Hardening

# Update SMB to the latest version (Ensure Windows is up to date)
Write-Output "Please ensure Windows is up to date to have the latest SMB version."

# Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

# Enable SMB Signing
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force

# Disable anonymous login
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Value 1

# Enforce NTLMv2
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5

# Disable execution from shares (This requires setting the appropriate NTFS permissions on shared folders)
Write-Output "Ensure that NTFS permissions on shared folders are set to prevent execution."

# Disable NetBIOS over TCP/IP (This might require a restart and affects network communications)
Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.TcpipNetbiosOptions -ne 2} | ForEach-Object {
    $_.SetTcpipNetbios(2)
}
