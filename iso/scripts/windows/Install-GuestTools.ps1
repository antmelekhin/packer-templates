# Mount Guest Tools ISO.
if ($env:PACKER_BUILDER_TYPE -ne 'hyperv-iso') {
    $MountResult = Mount-DiskImage -ImagePath 'C:/Windows/Temp/GuestTools.iso'

    # Identify Letter of mounted ISO.
    $DriveLetter = ($MountResult | Get-Volume).DriveLetter


    # Install Guest Tools.
    switch ($env:PACKER_BUILDER_TYPE) {
        vmware-iso {
            Write-Output 'Installing VMWare Guest Tools.'
            Start-Process -FilePath ($DriveLetter + ':\setup64.exe') -ArgumentList '/v"/qn REBOOT=R"' -Wait
        }
        virtualbox-iso {
            Write-Output 'Installing Virtualbox Guest Tools.'
            $CertificatePath = ($DriveLetter + ':\cert\')
            Get-ChildItem $CertificatePath *.cer | ForEach-Object { & ($CertificatePath + 'VBoxCertUtil.exe') add-trusted-publisher $_.FullName --root $_.FullName }
            Start-Process -FilePath ($DriveLetter + ':\VBoxWindowsAdditions.exe') -ArgumentList '/S' -Wait
        }
    }
}