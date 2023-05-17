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
    "../../_images/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso",
    "https://software-static.download.prss.microsoft.com/pr/download/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
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
  default     = "./windows.sum"
}

// Virtual Machine Settings
variable "cpus" {
  description = "The number of cpus to use for building the VM."
  type        = string
  default     = "2"
}

variable "memory" {
  description = "The amount of memory to use for building the VM in megabytes."
  type        = string
  default     = "4096"
}

variable "disk_size" {
  description = "The size, in megabytes, of the hard disk to create for the VM."
  type        = string
  default     = "51200"
}

// Guest OS Settings
variable "admin_username" {
  description = "The administrator username that will be create and use to connect to WinRM."
  type        = string
  default     = "vagrant"
}

variable "admin_password" {
  description = "The administrator's password."
  type        = string
  default     = "vagrant"
}

variable "vm_guest_product_key" {
  description = "The product key used to install and to activate Windows."
  type        = string
  default     = ""
}

variable "vm_guest_os_name" {
  description = "The guest operating system name. Used for naming."
  type        = string
  default     = "server"
}

variable "vm_guest_os_version" {
  description = "The guest operating system version. Used for naming."
  type        = string
  default     = "2019"
}

variable "vm_guest_os_edition" {
  description = "The guest operating system edition. Used for naming."
  type        = string
  default     = "standardcore"
}

variable "vm_guest_os_image_index" {
  description = "Uses the index number to select the image to install."
  type        = number
  default     = null
}

variable "vm_guest_timezone" {
  description = "The computer's time zone."
  type        = string
  default     = "Russian Standard Time"
}

variable "vm_guest_input_locales" {
  description = "The system input locale and the keyboard layout."
  type        = set(string)
  default = [
    "0409:00000409",
    "0419:00000419"
  ]
}

variable "vm_guest_system_locale" {
  description = "The language for non-Unicode programs."
  type        = string
  default     = "ru-RU"
}

variable "vm_guest_ui_language" {
  description = "The system default user interface (UI) language."
  type        = string
  default     = "en-US"
}

variable "vm_guest_user_locale" {
  description = "The per-user settings used for formatting dates, times, currency, and numbers."
  type        = string
  default     = "ru-RU"
}

// Provisioning
variable "scripts" {
  description = "Provisioning scripts."
  type        = list(string)
  default = [
    "../../_common/windows/Install-Chocolatey.ps1",
    "./scripts/Install-GuestTools.ps1"
  ]
}

variable "shutdown_command" {
  description = <<-EOF
  The command to use to gracefully shutdown the machine once all provisioning is complete. 
  By default this command run sysprep utility and shutdown the machine.
  EOF
  type        = string
  default     = "E:\\PackerShutdown.bat"
}
