$WindowsBuild = (Get-WmiObject Win32_OperatingSystem).BuildNumber
if ($WindowsBuild -ge '17763') {
    # Get OpenSSH Packages
    $OpenSSHPackages = Get-WindowsCapability -Online | Where-Object { $_.Name -like 'OpenSSH*' }

    # Install OpenSSH Client and Server
    foreach ($Package in $OpenSSHPackages) {
        Add-WindowsCapability -Online -Name $Package.Name
    }

    # Start OpenSSH Server
    Start-Service -Name sshd
    Set-Service -Name sshd -StartupType 'Automatic'
}

else {
    # Get OpenSSH Packages
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    (New-Object System.Net.WebClient).DownloadFile('https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta/OpenSSH-Win64.zip', "$env:TEMP\OpenSSH-Win64.zip")

    # Install OpenSSH Client and Server
    New-Item -ItemType Directory -Path "$env:ProgramFiles\OpenSSH" -Force

    Add-Type -Assembly "System.IO.Compression.Filesystem"
    $Zip = [IO.Compression.ZipFile]::OpenRead("$env:TEMP\OpenSSH-Win64.zip")

    $Entries = $Zip.Entries | Where-Object { $_.FullName -like 'OpenSSH-Win64/*' -and $_.FullName -ne 'OpenSSH-Win64/' }
    $Entries | ForEach-Object { [IO.Compression.ZipFileExtensions]::ExtractToFile( $_, "$env:ProgramFiles\OpenSSH\" + $_.Name) }

    $Zip.Dispose()

    # Add OpenSSH folder PATH to Environment Variables
    Set-Item -Path Env:Path -Value ($Env:Path + ';C:\Program Files\OpenSSH')

    # Install sshd service
    & 'C:\Program Files\OpenSSH\install-sshd.ps1'

    # Start OpenSSH Server
    Start-Service sshd
    Set-Service sshd -StartupType 'Automatic'

    # Fix Host Key files permissions
    & 'C:\Program Files\OpenSSH\FixHostFilePermissions.ps1' -Confirm:$false
}

# Set up Firewall Rule for OpenSSH Server
Get-NetFirewallRule -Name *ssh* | Remove-NetFirewallRule
New-NetFirewallRule `
    -Group 'OpenSSH Server' `
    -DisplayName 'OpenSSH Server (sshd)' `
    -Name 'OpenSSH-Server-In-TCP' `
    -LocalPort 22 `
    -Action Allow `
    -Protocol TCP `
    -Direction Inbound `
    -Enabled True

# Set Powershell as default shell
New-ItemProperty `
    -Path "HKLM:\SOFTWARE\OpenSSH" `
    -Name DefaultShell `
    -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -PropertyType String `
    -Force