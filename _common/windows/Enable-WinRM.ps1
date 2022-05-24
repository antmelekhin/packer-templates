# Switch network connection to private mode.
$NetProfile = Get-NetConnectionProfile
if ($NetProfile.NetworkCategory -eq 'Public') {
    Set-NetConnectionProfile -Name $NetProfile.Name -NetworkCategory Private
}

# Enable WinRM.
Set-WSManQuickConfig -Force

# Remove any existing Windows Management listeners.
Remove-Item -Path 'WSMan:\localhost\listener\listener*' -Recurse

# Create self-signed cert for encrypted WinRM on port 5986.
Remove-Item -Path 'Cert:\LocalMachine\My\*'
$Certificate = New-SelfSignedCertificate -CertStoreLocation 'Cert:\LocalMachine\My' -DnsName $env:COMPUTERNAME -Subject $env:COMPUTERNAME
New-Item -Path 'WSMan:\localhost\listener' -Transport HTTPS -Address * -CertificateThumbPrint $Certificate.Thumbprint -HostName $env:COMPUTERNAME -Force
New-Item -Path 'WSMan:\localhost\listener' -Transport HTTP -Address * -Force

# Block WinRM Basic authentification.
Set-Item -Path 'WSMan:\localhost\Service\Auth\Basic' -Value $false

# Block transfer of unencrypted data on the WinRM service.
Set-Item -Path 'WSMan:\localhost\Client\AllowUnencrypted' -Value $false
Set-Item -Path 'WSMan:\localhost\Service\AllowUnencrypted' -Value $false

# Ensure LocalAccountTokenFilterPolicy is set to 1
# https://github.com/ansible/ansible/issues/42978
$TokenPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$TokenPropName = 'LocalAccountTokenFilterPolicy'
$TokenKey = Get-Item -Path $TokenPath
$TokenValue = $TokenKey.GetValue($TokenPropName, $null)
if ($TokenValue -ne 1) {
    Write-Verbose 'Setting LocalAccountTokenFilterPolicy to 1'
    if ($null -ne $TokenValue) {
        Remove-ItemProperty -Path $TokenPath -Name $TokenPropName
    }
    $null = New-ItemProperty -Path $TokenPath -Name $TokenPropName -Value 1 -PropertyType DWORD
}

# Create WinRM Firewall Rules.
# WinRM over SSL Rule.
Get-NetFirewallRule -Name 'WINRM-HTTPS-In-TCP' | Remove-NetFirewallRule
Get-NetFirewallRule -DisplayName 'Windows Remote Management (HTTPS-In)' | Remove-NetFirewallRule

New-NetFirewallRule `
    -Group 'Windows Remote Management' `
    -DisplayName 'Windows Remote Management (HTTPS-In)' `
    -Name 'WINRM-HTTPS-In-TCP' `
    -LocalPort 5986 `
    -Action Allow `
    -Protocol TCP `
    -Program System `
    -Enabled True

# WinRM Rule.
Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' | Set-NetFirewallRule -Enabled True