Start-Job -ScriptBlock {
    $servicesToMonitor = @("DNS Server", "sshd", "ssh-agent", "Microsoft FTP Service")  # DNS, SSH, FTP

    while ($true) {
        foreach ($serviceName in $servicesToMonitor) {
            $service = Get-Service -Name $serviceName
            if ($service.Status -eq "Stopped") {
                Start-Service -Name $serviceName
                Write-Output "$serviceName service was stopped and has now been started."
            }
        }
        Start-Sleep -Seconds 10  # Check every 10 seconds
    }
}