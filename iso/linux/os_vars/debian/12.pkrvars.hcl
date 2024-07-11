// Guest OS settings
vm_guest_distr_name    = "debian"
vm_guest_distr_version = "12"

// VirtualBox specific settings
vbox_guest_os_type = "Debian_64"

// Removable media settings
iso_checksum_file = "https://cdimage.debian.org/cdimage/archive/12.5.0/amd64/iso-cd/SHA256SUMS"
iso_urls = [
  "../../_images/debian-12.5.0-amd64-netinst.iso",
  "https://cdimage.debian.org/cdimage/archive/12.5.0/amd64/iso-cd/debian-12.5.0-amd64-netinst.iso"
]

// Boot and Shutdown settings
boot_command_bios = [
  "<esc><wait>",
  "auto ",
  "net.ifnames=0 ",
  "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "<enter>"
]

boot_command_efi = [
  "<wait>c<wait>",
  "linux /install.amd/vmlinuz ",
  "auto-install/enable=true ",
  "debconf/priority=critical ",
  "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
  "vga=788 noprompt quiet --<enter>",
  "initrd /install.amd/initrd.gz<enter>",
  "boot<enter>"
]