# LOG
Start-Transcript -Path "$env:windir\Panther\SetupComplete.log" -IncludeInvocationHeader -Force

# SET WINRM
& "$PSScriptRoot\Enable-WinRM.ps1"

# DELETE ITSELF
Remove-Item -Path 'C:\Windows\System32\Sysprep\unattend.xml'
Remove-Item -Path 'C:\Windows\Setup\Scripts\*'