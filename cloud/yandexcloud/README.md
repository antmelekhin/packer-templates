Simple usage
============

```bash
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
export YC_TOKEN=$(yc config get token)
export PACKER_WINRM_PASSWORD="Passw0rd"
```

```powershell
$env:YC_CLOUD_ID=(yc config get cloud-id)
$env:YC_FOLDER_ID=(yc config get folder-id)
$env:YC_TOKEN=(yc config get token)
$env:PACKER_WINRM_PASSWORD="Passw0rd"
```

* `packer validate windows-2019.json`
* `packer build windows-2019.json`
