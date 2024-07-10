variable "headless" {
  description = "Packer defaults to building virtual machines by launching a GUI that shows the console of the machine being built."
  type        = bool
  default     = true
}

// Removable media settings
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
  default     = null
}

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
  default     = null
}

// Virtual Machine settings
variable "cpus" {
  description = "The number of cpus to use for building the VM."
  type        = number
  default     = 1
}

variable "disk_size" {
  description = "The size, in megabytes, of the hard disk to create for the VM."
  type        = number
  default     = 12400
}

variable "memory" {
  description = "The amount of memory to use for building the VM in megabytes."
  type        = number
  default     = 1024
}

variable "firmware" {
  description = "The firmware to be used: BIOS or EFI."
  type        = string
  default     = "efi"
}

// Hyper V specific settings
variable "hyperv_enable_dynamic_memory" {
  description = "If true enable dynamic memory for the virtual machine."
  type        = bool
  default     = true
}

variable "hyperv_switch_name" {
  description = "The name of the switch to connect the virtual machine to."
  type        = string
  default     = "Default Switch"
}

// VirtualBox specific settings
variable "vbox_guest_os_type" {
  description = "The guest OS type being installed."
  type        = string
  default     = null
}

variable "vbox_hard_drive_interface" {
  description = "The type of controller that the primary hard drive is attached to."
  type        = string
  default     = "sata"
}

variable "vbox_iso_interface" {
  description = "The type of controller that the ISO is attached to."
  type        = string
  default     = "sata"
}

variable "vboxmanage" {
  description = "Custom VBoxManage commands to execute in order to further customize the virtual machine being created."
  type        = list(list(string))
  default = [
    ["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
  ]
}

// Guest OS settings
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
  description = "The guest Linux distribution name. Used for naming."
  type        = string
  default     = null
}

variable "vm_guest_distr_version" {
  description = "The guest Linux distribution version. Used for naming."
  type        = string
  default     = null
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

// Boot and Shutdown settings
variable "boot_command_bios" {
  description = "This is an array of commands to type when the virtual machine is first booted (BIOS)."
  type        = list(string)
  default     = null
}

variable "boot_command_efi" {
  description = "This is an array of commands to type when the virtual machine is first booted (EFI)."
  type        = list(string)
  default     = null
}
variable "boot_wait" {
  description = "The time to wait after booting the initial virtual machine before typing the `boot_command`."
  type        = string
  default     = "5s"
}

variable "shutdown_command" {
  description = <<-EOF
  The command to use to gracefully shutdown the machine once all provisioning is complete.
  By default this command run sysprep utility and shutdown the machine.
  EOF
  type        = string
  default     = "sudo shutdown -P now"
}
