# PowerShell equivalent script

# Variables
$excludeUser = "seccdc_black"
$administratorGroup = @(
    "elara.boss",
    "sarah.lee",
    "lisa.brown",
    "michael.davis",
    "emily.chen",
    "tom.harris",
    "bob.johnson",
    "david.kim",
    "rachel.patel",
    "dave.grohl",
    "kate.skye",
    "leo.zenith",
    "jack.rover",
    "Administrator"
)

function UserIsAdmin {
    param (
        [string]$username
    )
    $isAdmin = $False
    foreach ($admin in $administratorGroup) {
        if ($username -eq $admin) {
            $isAdmin = $True
            break
        }
    }
    return $isAdmin
}

$hostname = $env:COMPUTERNAME
$outputFile = "C:\root\TEAM34_${hostname}_SSH_PASSWD.csv"

$keyDir = "C:\etc\ssh\shared_keys"
if (-not (Test-Path -Path $keyDir)) {
    New-Item -ItemType Directory -Path $keyDir
    Write-Host "Directory created at $keyDir"
}

$sshKey = Join-Path $keyDir "shared_key"
if (-not (Test-Path -Path $sshKey)) {
    ssh-keygen -t rsa -b 4096 -f $sshKey -N ''
    Write-Host "Shared SSH key pair generated."
} else {
    Write-Host "Shared SSH key pair already exists."
}

$sharedPassphrase = Read-Host "Enter the new passphrase for all users (except for logging $excludeUser)" -AsSecureString
$sharedPassphraseBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sharedPassphrase)
$sharedPassphrasePlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($sharedPassphraseBstr)

if ([string]::IsNullOrWhiteSpace($sharedPassphrasePlain)) {
    Write-Host "Passphrase cannot be empty. Exiting..."
    exit
}

if (-not (Test-Path -Path $outputFile)) {
    New-Item -ItemType File -Path $outputFile
    Write-Host "Output file created at $outputFile"
}

Get-LocalUser | Where-Object { $_.Name -ne $excludeUser } | ForEach-Object {
    $username = $_.Name
    $user = $_
    if ((Get-LocalUser -Name $username).Enabled -eq $True) {
        $passwordChange = $user | Set-LocalUser -Password (ConvertTo-SecureString $sharedPassphrasePlain -AsPlainText -Force)
        if ($passwordChange) {
            Write-Host "Password changed for $username"
            if (-not (UserIsAdmin $username)) {
                Add-Content -Path $outputFile -Value "HOSTNAME-SERVICE,$username,$sharedPassphrasePlain"
            }
        } else {
            Write-Host "Failed to change password for $username"
            continue
        }

        $userSshDir = Join-Path (Resolve-Path ("C:\Users\" + $username)).Path ".ssh"
        if (-not (Test-Path -Path $userSshDir)) {
            New-Item -ItemType Directory -Path $userSshDir
        }
        Set-ACL -Path $userSshDir -AclObject (Get-Acl -Path $userSshDir).SetOwner([System.Security.Principal.WindowsIdentity]::GetCurrent().User)
        Copy-Item -Path $sshKey -Destination $userSshDir -Force
        Copy-Item -Path ("$sshKey.pub") -Destination $userSshDir -Force
        Set-Content -Path (Join-Path $userSshDir "authorized_keys") -Value (Get-Content -Path "$sshKey.pub")
        Write-Host "Shared SSH keys set for $username."
    }
}

Write-Host "Script completed. User details, except for administratorGroup, written to $outputFile."