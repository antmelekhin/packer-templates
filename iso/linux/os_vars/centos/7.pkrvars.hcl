// Guest OS settings
vm_guest_distr_name    = "centos"
vm_guest_distr_version = "7"

// VirtualBox specific settings
vbox_guest_os_type = "RedHat_64"

// Removable media settings
iso_url      = "../../_images/CentOS-7-x86_64-NetInstall-2009.iso"
iso_checksum = "b79079ad71cc3c5ceb3561fff348a1b67ee37f71f4cddfec09480d4589c191d6"

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