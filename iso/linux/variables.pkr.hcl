variable "headless" {
  description = "Packer defaults to building virtual machines by launching a GUI that shows the console of the machine being built."
  type        = bool
  default     = true
}

// Removable Media Settings
variable "iso_url" {
  description = "A URL to the ISO containing the installation image."
  type        = string
  default     = null
}

variable "iso_urls" {
  description = <<-EOF
  Multiple URLs for the ISO to download.
  `iso_urls` is ignored if `iso_url` is set.
  EOF
  type        = set(string)
  default = [
    "../../_images/debian-11.7.0-amd64-netinst.iso",
    "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.7.0-amd64-netinst.iso"
  ]
}

variable "iso_checksum" {
  description = "The checksum for the ISO file or virtual hard drive file."
  type        = string
  default     = null
}

variable "iso_checksum_file" {
  description = <<-EOF
  A file that contains checksum for the ISO file or virtual hard drive file.
  `iso_checksum_file` is ignored if `iso_checksum` is set.
  EOF
  type        = string
  default     = "./linux.sum"
}

// Virtual Machine Settings
variable "cpus" {
  description = "The number of cpus to use for building the VM."
  type        = string
  default     = "1"
}

variable "memory" {
  description = "The amount of memory to use for building the VM in megabytes."
  type        = string
  default     = "1024"
}

variable "disk_size" {
  description = "The size, in megabytes, of the hard disk to create for the VM."
  type        = string
  default     = "10000"
}

variable "firmware" {
  description = "The firmware to be used: BIOS or EFI."
  type        = string
  default     = "efi"
}

// VirtualBox specific settings
variable "guest_os_type" {
  description = "The guest OS type being installed."
  type        = string
  default     = "Debian_64"
}

// Hyper V specific settings
variable "switch_name" {
  description = "The name of the switch to connect the virtual machine to."
  type        = string
  default     = "Default Switch"
}

variable "enable_dynamic_memory" {
  description = "If true enable dynamic memory for the virtual machine."
  type        = bool
  default     = true
}

// Guest OS Settings
variable "admin_username" {
  description = "The administrator username that will be create and use to connect to SSH."
  type        = string
  default     = "vagrant"
}

variable "admin_password" {
  description = "The administrator's password."
  type        = string
  default     = "vagrant"
}

variable "vm_guest_distr_name" {
  description = "The guest linux distribution name. Used for naming."
  type        = string
  default     = "debian"
}

variable "vm_guest_distr_version" {
  description = "The guest linux distribution version. Used for naming."
  type        = string
  default     = "11"
}

variable "vm_guest_distr_edition" {
  description = "The guest linux distribution edition. Used for naming."
  type        = string
  default     = "server"
}

variable "vm_guest_repository_mirror" {
  description = "A repository mirror URL. Not used in RHEL builds."
  type        = string
  default     = "mirror.yandex.ru"
}

variable "vm_guest_timezone" {
  description = "The computer's time zone."
  type        = string
  default     = "Europe/Moscow"
}

// Boot and Shutdown Settings
variable "boot_command_bios" {
  description = "This is an array of commands to type when the virtual machine is first booted (BIOS)."
  type        = list(string)
  default = [
    "<esc><wait>",
    "auto ",
    "net.ifnames=0 ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<enter>"
  ]
}

variable "boot_command_efi" {
  description = "This is an array of commands to type when the virtual machine is first booted (EFI)."
  type        = list(string)
  default = [
    "<wait>c<wait>",
    "linux /install.amd/vmlinuz ",
    "auto-install/enable=true ",
    "debconf/priority=critical ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "vga=788 noprompt quiet --<enter>",
    "initrd /install.amd/initrd.gz<enter>",
    "boot<enter>"
  ]
}

variable "shutdown_command" {
  description = <<-EOF
  The command to use to gracefully shutdown the machine once all provisioning is complete. 
  By default this command run sysprep utility and shutdown the machine.
  EOF
  type        = string
  default     = "sudo shutdown -P now"
}
