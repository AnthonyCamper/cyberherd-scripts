# SMB Audits

# Check files on shares
Get-SmbShare -Name * | ForEach-Object { Get-SmbShareAccess -Name $_.Name }

# Check SMB version
Get-SmbConnection

# Check SMBv1
Get-WindowsFeature FS-SMB1

# Check NTLMv1 (Registry check, might require elevated permissions)
$ntlmv1Status = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel"
if ($ntlmv1Status.LmCompatibilityLevel -le 2) {
    Write-Output "NTLMv1 is enabled or might be enabled. Consider enforcing NTLMv2 for better security."
} else {
    Write-Output "NTLMv1 is disabled."
}