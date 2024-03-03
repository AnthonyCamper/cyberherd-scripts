# FTP Audits

# Audit files in FTP root
$ftpRoot = "C:\inetpub\ftproot" # Change this path to your FTP root
Get-ChildItem -Path $ftpRoot -Recurse | Select-Object FullName, Length, LastWriteTime