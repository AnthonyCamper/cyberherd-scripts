# Stop the Print Spooler service
Stop-Service -Name Spooler -Force

# Disable the Print Spooler service
Set-Service -Name Spooler -StartupType Disabled

Write-Host "Print Spooler service has been stopped and disabled."