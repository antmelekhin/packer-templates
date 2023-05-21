// Guest OS Metadata
vm_guest_distr_name    = "centos"
vm_guest_distr_version = "7"

// Virtual Machine Settings
guest_os_type = "RedHat_64"

// Removable Media Settings
iso_urls = [
  "../../_images/CentOS-7-x86_64-NetInstall-2009.iso",
  "http://mirror.yandex.ru/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-NetInstall-2009.iso"
]

// Boot and Shutdown Settings
boot_command = [
  "<esc>",
  "<wait>",
  "linux inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg biosdevname=0 net.ifnames=0",
  "<enter>"
]