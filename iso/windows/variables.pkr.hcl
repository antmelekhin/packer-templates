variable "headless" {
  type    = bool
  default = true
}

variable "iso_urls" {
  type = list(string)
  default = [
    "../../_images/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso",
    "https://software-static.download.prss.microsoft.com/pr/download/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
  ]
}

variable "iso_checksum" {
  type    = string
  default = "./windows.sum"
}

variable "vm_name" {
  type    = string
  default = "windows-2019-core"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "4096"
}

variable "disk_size" {
  type    = string
  default = "51200"
}

variable "admin_username" {
  type    = string
  default = "vagrant"
}

variable "admin_password" {
  type    = string
  default = "vagrant"
}

variable "scripts" {
  type = list(string)
  default = [
      "../../_common/windows/Install-Chocolatey.ps1",
      "../../_common/windows/Install-OpenSSH.ps1",
      "./scripts/Install-GuestTools.ps1",
      // "../../_common/windows/Install-WindowsUpdates.ps1"
    ]
}