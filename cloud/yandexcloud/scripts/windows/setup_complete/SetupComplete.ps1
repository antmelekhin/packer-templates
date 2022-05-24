# LOG
Start-Transcript -Path "$env:windir\Panther\SetupComplete.log" -IncludeInvocationHeader -Force

# WAIT CLOUDBASE-INIT
while ((Get-Service 'cloudbase-init').Status -eq 'Running') {
    Start-Sleep -Seconds 10
    Write-Host 'Waiting cloudbase-init to stop'
}

$SerialPort = New-Object System.IO.Ports.SerialPort('COM1')

while ($SerialPort.IsOpen) {
    Start-Sleep -Seconds 10
    Write-Host 'Waiting COM1 port to become availible'
}

$SerialPort.Open()

# WRITE COM1 PORT
filter Out-Serial {
    $SerialPort.WriteLine("[$((Get-Date).ToString())]::[SETUPCOMPLETE]::$_")
}

# GET METADATA
function Get-InstanceMetadata ($SubPath) {
    $Headers = @{ 'Metadata-Flavor' = 'Google' }
    $Uri = 'http://169.254.169.254/computeMetadata/v1/instance' + $SubPath

    Invoke-RestMethod -Headers $Headers -Uri $Uri
}

# CORRECT ETH
'Rename network adapters' | Out-Serial
$ethIndexes = (Get-InstanceMetadata -SubPath '/network-interfaces/') -replace '/'
foreach ($index in $ethIndexes) {
    $MacAddress = Get-InstanceMetadata -SubPath "/network-interfaces/$index/mac"
    Get-NetAdapter | Where-Object MacAddress -eq ($MacAddress -replace ':', '-') | `
        Rename-NetAdapter -NewName "eth$index"
}

# SET SHUTDOWN POLICY
'Allow react on ACPI calls' | Out-Serial
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'shutdownwithoutlogon' -Value 1

# SET WINRM
'Set WinRM' | Out-Serial

& .\Enable-WinRM.ps1

# FIREWALL
'Enable ICMP Rule' | Out-Serial
Get-NetFirewallRule -Name 'vm-monitoring-icmpv4' | Set-NetFirewallRule -Enabled True

# DELETE ITSELF
'Remove itself' | Out-Serial
Remove-Item -Path 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\*'
Remove-Item -Path 'C:\Windows\Setup\Scripts\*'

# COMPLETE
"Complete, logs located at: $env:windir\Panther\SetupComplete.log" | Out-Serial