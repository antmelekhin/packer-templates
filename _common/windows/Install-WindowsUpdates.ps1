# Install Nuget Package provider.
Install-PackageProvider -Name Nuget -Force

# Install Windows Update module.
Install-Module -Name PSWindowsUpdate -Force

# Install updates.
try {
    # Create Scheduled Task.
    $LogPath = 'C:\Windows\Temp\PSWindowsUpdate.log'
    $UpdateCommand = [ScriptBlock]::Create("Get-WUInstall -AcceptAll -Install -IgnoreReboot | Out-File $LogPath")

    $TaskName = 'PackerUpdate'

    $User = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Scheduler = New-Object -ComObject Schedule.Service

    $Task = $Scheduler.NewTask(0)

    $RegistrationInfo = $Task.RegistrationInfo
    $RegistrationInfo.Description = $TaskName
    $RegistrationInfo.Author = $User.Name

    $Settings = $Task.Settings
    $Settings.Enabled = $True
    $Settings.StartWhenAvailable = $True
    $Settings.Hidden = $False

    $Action = $Task.Actions.Create(0)
    $Action.Path = 'powershell'
    $Action.Arguments = "-Command $UpdateCommand"

    $Task.Principal.RunLevel = 1

    $Scheduler.Connect()
    $RootFolder = $Scheduler.GetFolder('\')
    $null = $RootFolder.RegisterTaskDefinition($TaskName, $Task, 6, 'SYSTEM', $null, 1)
    $null = $RootFolder.GetTask($TaskName).Run(0)

    Write-Output 'The Windows Update log will be displayed below this message. No additional output indicates no updates were needed.'
    do {
        Start-Sleep -Seconds 1
        if ((Test-Path $LogPath) -and $null -eq $script:reader) {
            $script:stream = New-Object System.IO.FileStream -ArgumentList $LogPath, Open, Read, ReadWrite
            $script:reader = New-Object System.IO.StreamReader $stream
        }
        if ($null -ne $script:reader) {
            $line = $null
            do {
                $line = $script:reader.ReadLine()
                Write-Output $line
            }
            while ($null -ne $line)
        }
    }
    while ($Scheduler.GetRunningTasks(0) | Where-Object { $_.Name -eq $TaskName })
}

finally {
    $RootFolder.DeleteTask($TaskName, 0)
    $null = [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Scheduler)
    if ($null -ne $script:reader) {
        $script:reader.Close()
        $script:stream.Dispose()
    }
}

Write-Output 'Ended Windows Updates Installation.'