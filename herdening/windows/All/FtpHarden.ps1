# Disable anonymous login and plain FTP
Import-Module WebAdministration

# Disable anonymous login
Set-WebConfigurationProperty -pspath 'IIS:\Sites\YourFTPSiteName' -filter "system.ftpServer/security/authentication/anonymousAuthentication" -name "enabled" -value $False

# Disable plain FTP by enabling SSL (FTPS)
Set-WebConfigurationProperty -pspath 'IIS:\Sites\YourFTPSiteName' -filter "system.ftpServer/security/ssl" -name "controlChannelPolicy" -value "SslRequire"
Set-WebConfigurationProperty -pspath 'IIS:\Sites\YourFTPSiteName' -filter "system.ftpServer/security/ssl" -name "dataChannelPolicy" -value "SslRequire"

# Note: Replace 'YourFTPSiteName' with the name of your FTP site in IIS

# Disable weak encryption schemes
# This step requires manually editing the applicationHost.config file or using IIS Crypto software to disable specific ciphers

# Blocklist filetypes (executables)
# This requires using IIS Request Filtering feature
Add-WebConfiguration "/system.ftpServer/security/requestFiltering" -value @{fileExtensions = @{allowUnlisted = $true; add = @{fileExtension = '.exe'; allowed = $false}}}

# Disable exec
# Ensure the FTP user account used for connections does not have execute permissions on the server

# Disable writing
# Modify NTFS permissions on the FTP root and subfolders to be read-only for the FTP user accounts
