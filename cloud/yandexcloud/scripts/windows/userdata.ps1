<powershell>

$AdminPassword = Invoke-RestMethod -Headers @{ 'Metadata-Flavor' = 'Google' } 'http://169.254.169.254/computeMetadata/v1/instance/attributes/winrm_password'
net user Administrator $AdminPassword

Remove-Item -Path 'C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\*'
Remove-Item -Path 'WSMan:\localhost\listener\listener*' -Recurse
Remove-Item -Path 'Cert:\LocalMachine\My\*'
$DnsName = Invoke-RestMethod -Headers @{ 'Metadata-Flavor' = 'Google' } 'http://169.254.169.254/computeMetadata/v1/instance/hostname'
$HostName = Invoke-RestMethod -Headers @{ 'Metadata-Flavor' = 'Google' } 'http://169.254.169.254/computeMetadata/v1/instance/name'
$Certificate = New-SelfSignedCertificate -CertStoreLocation 'Cert:\LocalMachine\My' -DnsName $DnsName -Subject $HostName
New-Item -Path 'WSMan:\localhost\listener' -Transport HTTPS -Address * -HostName $HostName -CertificateThumbPrint $Certificate.Thumbprint -Force

</powershell>