$ErrorActionPreference = 'Stop'

$SpaceAtStart = [Math]::Round( ((Get-WmiObject win32_logicaldisk | Where-Object { $_.DeviceID -eq $env:SystemDrive }).FreeSpace) / 1GB, 2)

# Clear downloaded updates
Stop-Service -Name wuauserv -Force
Remove-Item -Path "$env:windir\SoftwareDistribution\*" -ErrorAction:SilentlyContinue -Recurse
Start-Service -Name wuauserv

# Cleanup Windows Update area after all that
Write-Output 'Cleaning up WinSxS updates'
Start-Process -FilePath "$env:SystemRoot\system32\Dism.exe" -ArgumentList '/Online /Cleanup-Image /StartComponentCleanup /ResetBase' -NoNewWindow -Wait

# Set registry keys for all the other cleanup areas we want to address with cleanmgr - fairly comprehensive cleanup
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\').InstallationType -ne 'Server Core') {
    $VolumeCaches = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches'
    Get-ItemProperty -Path "$VolumeCaches\*" | ForEach-Object {
        New-ItemProperty -Path $_.PSPath -Name 'StateFlags0012' -Value '2' -PropertyType 'DWord'
    }

    # Run Cleanmgr utility
    Write-Output 'Running CleanMgr with Sagerun:12'
    Start-Process -FilePath "$env:SystemRoot\system32\cleanmgr.exe" -ArgumentList '/sagerun:12' -NoNewWindow -Wait

    Get-ItemProperty -Path "$VolumeCaches\*" -Name 'StateFlags0012' | Remove-ItemProperty -Name 'StateFlags0012'
}

# Clean up files
Write-Output 'Clearing Files'

# Clear Panther logs
Remove-Item -Path "$env:windir\PANTHER\*" -filter '*.log' -ErrorAction:SilentlyContinue -Recurse
Remove-Item -Path "$env:windir\PANTHER\*" -filter '*.xml' -ErrorAction:SilentlyContinue -Recurse

# Clear Temp files
Remove-Item -Path "$env:windir\TEMP\*" -Exclude '*.ps1' -ErrorAction:SilentlyContinue -Recurse
Remove-Item -Path "$env:TEMP\*" -ErrorAction:SilentlyContinue -Recurse
Remove-Item -Path "$env:TMP\*" -ErrorAction:SilentlyContinue -Recurse

# Clear WER files
Remove-Item -Path "$env:ProgramData\Microsoft\Windows\WER\ReportArchive\*" -ErrorAction:SilentlyContinue -Recurse
Remove-Item -Path "$env:ProgramData\Microsoft\Windows\WER\ReportQueue\*" -ErrorAction:SilentlyContinue -Recurse
Remove-Item -Path "$env:ProgramData\Microsoft\Windows\WER\Temp\*" -ErrorAction:SilentlyContinue -Recurse

# Clearing Logs
Write-Output 'Clearing Logs'

# Clear Windows system logs
Remove-Item -Path "$env:SystemRoot\Logs\*" -ErrorAction:SilentlyContinue -Recurse

# Clear Event logs
Get-EventLog -LogName * | ForEach-Object { Clear-EventLog -LogName $_.Log }

Write-Output 'Running Volume Optimizer'
Optimize-Volume -DriveLetter 'C' -Verbose

# Display Free Space Statistics at end
$SpaceAtEnd = [Math]::Round( ((Get-WmiObject win32_logicaldisk | Where-Object { $_.DeviceID -eq $env:SystemDrive }).FreeSpace) / 1GB, 2)
$SpaceReclaimed = [Math]::Round( ($SpaceAtEnd - $SpaceAtStart), 2)

Write-Output 'Cleaning Complete'
Write-Output "Starting Free Space $SpaceAtStart GB"
Write-Output "Current Free Space $SpaceAtEnd GB"
Write-Output "Reclaimed $SpaceReclaimed GB"

# Sleep to let console log catch up (and get captured by packer)
Start-Sleep -Seconds 20