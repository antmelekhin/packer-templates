// Guest OS settings
vm_guest_os_name    = "centos"
vm_guest_os_version = "7"

// VirtualBox specific settings
vbox_guest_os_type = "RedHat_64"

// Removable media settings
iso_checksum_file = "https://mirror.yandex.ru/centos/centos/7/isos/x86_64/sha256sum.txt"
iso_urls = [
  "../../images/CentOS-7-x86_64-NetInstall-2009.iso",
  "https://mirror.yandex.ru/centos/centos/7/isos/x86_64/CentOS-7-x86_64-NetInstall-2009.iso"
]

// Boot and Shutdown settings
boot_command_bios = [
  "<esc>",
  "<wait>",
  "linux inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg biosdevname=0 net.ifnames=0",
  "<enter>"
]

boot_command_efi = [
  "<wait>c<wait>",
  "setparams kickstart<enter>",
  "linuxefi /images/pxeboot/vmlinuz ",
  "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<enter>",
  "initrdefi /images/pxeboot/initrd.img<enter>",
  "boot<enter>"
]
