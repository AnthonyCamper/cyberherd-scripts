Add-WindowsFeature Web-Server; Add-WindowsFeature Web-Ftp-Server -IncludeAllSubFeature; Import-Module WebAdministration; $FTPSiteName = "Default FTP Site"; $FTPRootDir = "C:\"; $FTPPort = 21; New-WebFtpSite -Name $FTPSiteName -Port $FTPPort -PhysicalPath $FTPRootDir