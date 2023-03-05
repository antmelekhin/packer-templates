& "$env:SystemRoot\System32\Sysprep\Sysprep.exe" /oobe /generalize /quiet /quit /unattend:"C:\Windows\System32\Sysprep\unattend.xml"

while ($true) {
    $ImageState = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State | Select-Object ImageState
    if ($ImageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') {
        Write-Output $ImageState.ImageState
        Start-Sleep -Seconds 10 
    }
    else { break }
}

Stop-Computer -Force