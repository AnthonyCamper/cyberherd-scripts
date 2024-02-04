# PowerShell Script to Automatically Install Windows Updates

# Create a Update Session COM object
$updateSession = New-Object -ComObject Microsoft.Update.Session
$updateSearcher = $updateSession.CreateUpdateSearcher()

Write-Host "Searching for updates..."
$searchResult = $updateSearcher.Search("IsInstalled=0")

if ($searchResult.Updates.Count -eq 0) {
    Write-Host "There are no applicable updates."
    exit
}

# Prepare collection of updates to download
$updatesToDownload = New-Object -ComObject Microsoft.Update.UpdateColl
foreach ($update in $searchResult.Updates) {
    $updatesToDownload.Add($update) | Out-Null
}

# Download updates
$downloader = $updateSession.CreateUpdateDownloader()
$downloader.Updates = $updatesToDownload
$downloadResult = $downloader.Download()
Write-Host "Download of updates: $($downloadResult.ResultCode)"

# Prepare collection of updates to install
$updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
foreach ($update in $searchResult.Updates) {
    if ($update.IsDownloaded) {
        $updatesToInstall.Add($update) | Out-Null
    }
}

# Install updates
$installer = $updateSession.CreateUpdateInstaller()
$installer.Updates = $updatesToInstall
$installationResult = $installer.Install()

# Output the result of installation
Write-Host "Installation Result: $($installationResult.ResultCode)"
Write-Host "Reboot Required: $($installationResult.RebootRequired)"

# Output detailed information about each update installed
foreach ($update in $installationResult.Updates) {
    Write-Host "Installed: $($update.Title)"
}

# PowerShell Script to Download and Install Malwarebytes

# Specify the URL for the Malwarebytes installer
# NOTE: This URL may change. Always verify the latest version from the official website.
$downloadUrl = "https://downloads.malwarebytes.com/file/mb4_offline"

# Specify the path where the installer will be saved
$installerPath = "$env:TEMP\mb-setup.exe"

# Download the installer
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

# Install Malwarebytes silently
# /verysilent: Silent installation with no user interface
# /norestart: Prevents the installer from restarting the system automatically
Start-Process -FilePath $installerPath -Args "/verysilent /norestart" -Wait -NoNewWindow

# Clean up the installer
Remove-Item -Path $installerPath

Write-Host "Malwarebytes installation completed."

# Enable Defender and Firewall
Set-MpPreference -DisableRealtimeMonitoring $false; Set-NetFirewallProfile -Profile Domain -Enabled True; Set-NetFirewallProfile -Profile Private -Enabled True; Set-NetFirewallProfile -Profile Public -Enabled True

# Enable Defender System Exploit Protection
Set-Processmitigation -System -Enable DEP,EmulateAtlThunks,BottomUp,HighEntropy,SEHOP,SEHOPTelemetry,TerminateOnError

# Enable thorough logging/auditing
auditpol /set /subcatergory: "Detailed File Share" /success:enable /failure:enable
auditpol /set /subcatergory: "File System" /success:enable /failure:enable
auditpol /set /subcatergory: "Security System Extension" /success:enable /failure:enable
auditpol /set /subcatergory: "System Integrity" /success:enable /failure:enable
auditpol /set /subcatergory: "Security State Change" /success:enable /failure:enable
auditpol /set /subcatergory: "Other System Events" /success:enable /failure:enable
auditpol /set /subcatergory: "System Integrity" /success:enable /failure:enable
auditpol /set /subcatergory: "Logon" /success:enable /failure:enable
auditpol /set /subcatergory: "Logoff" /success:enable /failure:enable
auditpol /set /subcatergory: "Account Lockout" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Logon/Logoff Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Network Policy Server" /success:enable /failure:enable
auditpol /set /subcatergory: "Registry" /success:enable /failure:enable
auditpol /set /subcatergory: "SAM" /success:enable /failure:enable
auditpol /set /subcatergory: "Certification Services" /success:enable /failure:enable
auditpol /set /subcatergory: "Application Generated" /success:enable /failure:enable
auditpol /set /subcatergory: "Handle Manipulation" /success:enable /failure:enable
auditpol /set /subcatergory: "Filtering Platform Packet Drop" /success:enable /failure:enable
auditpol /set /subcatergory: "Filtering Platform Connection" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Object Access Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Detailed File Share" /success:enable /failure:enable
auditpol /set /subcatergory: "Sensitive Privilege" /success:enable /failure:enable
auditpol /set /subcatergory: "Non Sensitive Privilege" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Privilege Use Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Process Termination" /success:enable /failure:enable
auditpol /set /subcatergory: "DPAPI Activity" /success:enable /failure:enable
auditpol /set /subcatergory: "RPC Activity" /success:enable /failure:enable
auditpol /set /subcatergory: "Process Creation" /success:enable /failure:enable
auditpol /set /subcatergory: "Audit Policy Change" /success:enable /failure:enable
auditpol /set /subcatergory: "Authentication Policy Change" /success:enable /failure:enable
auditpol /set /subcatergory: "MPSSVC Rule-Level Policy" /success:enable /failure:enable
auditpol /set /subcatergory: "Filtering Platform Policy" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Policy Change Events" /success:enable /failure:enable
auditpol /set /subcatergory: "User Account Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Computer Account Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Security Group Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Distribution Group" /success:enable /failure:enable
auditpol /set /subcatergory: "Application Group Management" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Account Management Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Directory Service Changes" /success:enable /failure:enable
auditpol /set /subcatergory: "Directory Service Replications" /success:enable /failure:enable
auditpol /set /subcatergory: "Detailed Directory Service Replications" /success:enable /failure:enable
auditpol /set /subcatergory: "Directory Service Access" /success:enable /failure:enable
auditpol /set /subcatergory: "Kerberos Service Ticket Operations" /success:enable /failure:enable
auditpol /set /subcatergory: "Other Account Logon Events" /success:enable /failure:enable
auditpol /set /subcatergory: "Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcatergory: "Credential Validation" /success:enable /failure:enable

