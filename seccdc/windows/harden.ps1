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