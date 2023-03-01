// The Packer configuration.

packer {
  required_version = ">= 1.8.3"
  required_plugins {
    hyperv = {
      version = ">= v1.0.4"
      source  = "github.com/hashicorp/hyperv"
    }
    virtualbox = {
      version = ">= v1.0.4"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

// Defines the local variables.

locals {
  vm_guest_input_locales = join(";", var.vm_guest_input_locales)
}

// Defines the builder configuration blocks.

source "hyperv-iso" "windows" {
  headless         = var.headless
  iso_urls         = var.iso_urls
  iso_checksum     = "file:${var.iso_checksum}"
  boot_command     = ["<spacebar>"]
  vm_name          = var.vm_name
  cpus             = var.cpus
  memory           = var.memory
  disk_size        = var.disk_size
  switch_name      = "Default Switch"
  generation       = 1
  communicator     = "winrm"
  winrm_username   = var.admin_username
  winrm_password   = var.admin_password
  winrm_use_ssl    = true
  winrm_insecure   = true
  winrm_use_ntlm   = true
  floppy_files = [
    "../../_common/windows/Enable-WinRM.ps1"
  ]
  cd_content = {
    "autounattend.xml" = templatefile(
      "${path.root}/answer_files/server/autounattend.pkrtpl.hcl",
      {
        username      = var.admin_username,
        password      = var.admin_password,
        timezone      = var.vm_guest_timezone,
        input_locale  = local.vm_guest_input_locales,
        system_locale = var.vm_guest_system_locale,
        ui_language   = var.vm_guest_ui_language,
        user_locale   = var.vm_guest_user_locale
      }
    ),
  }
}

source "virtualbox-iso" "windows" {
  headless             = var.headless
  guest_os_type        = "Windows10_64"
  iso_urls             = var.iso_urls
  iso_checksum         = "file:${var.iso_checksum}"
  boot_command         = ["<spacebar>"]
  vm_name              = var.vm_name
  hard_drive_interface = "sata"
  disk_size            = var.disk_size
  guest_additions_mode = "upload"
  guest_additions_path = "C:/Windows/Temp/GuestTools.iso"
  communicator         = "winrm"
  winrm_username       = var.admin_username
  winrm_password       = var.admin_password
  winrm_use_ssl        = true
  winrm_insecure       = true
  winrm_use_ntlm       = true
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--cpus", var.cpus],
    ["modifyvm", "{{ .Name }}", "--memory", var.memory]
  ]
  floppy_files = [
    "../../_common/windows/Enable-WinRM.ps1"
  ]
  cd_content = {
    "autounattend.xml" = templatefile(
      "${path.root}/answer_files/server/autounattend.pkrtpl.hcl",
      {
        username      = var.admin_username,
        password      = var.admin_password,
        timezone      = var.vm_guest_timezone,
        input_locale  = local.vm_guest_input_locales,
        system_locale = var.vm_guest_system_locale,
        ui_language   = var.vm_guest_ui_language,
        user_locale   = var.vm_guest_user_locale,
      }
    ),
  }
}

// Defines the builders to run, provisioners, and post-processors.

build {
  sources = [
    "source.hyperv-iso.windows",
    "source.virtualbox-iso.windows"
  ]

  provisioner "powershell" {
    elevated_password = var.admin_password
    elevated_user     = var.admin_username
    scripts           = var.scripts
  }

  provisioner "windows-restart" {
    restart_timeout = "15m"
  }

  provisioner "powershell" {
    elevated_password = var.admin_password
    elevated_user     = var.admin_username
    script            = "../../_common/windows/Start-Cleanup.ps1"
  }

  provisioner "windows-restart" {}

  provisioner "file" {
    source      = "./scripts/setup_complete/"
    destination = "C:\\Windows\\Setup\\Scripts\\"
  }

  provisioner "file" {
    source      = "../../_common/windows/Enable-WinRM.ps1"
    destination = "C:\\Windows\\Setup\\Scripts\\Enable-WinRM.ps1"
  }

  provisioner "file" {
    content = templatefile(
      "${path.root}/answer_files/server/unattend.pkrtpl.hcl",
      {
        timezone      = var.vm_guest_timezone,
        input_locale  = local.vm_guest_input_locales,
        system_locale = var.vm_guest_system_locale,
        ui_language   = var.vm_guest_ui_language,
        user_locale   = var.vm_guest_user_locale,
      }
    )
    destination = "C:\\Windows\\System32\\Sysprep\\unattend.xml"
  }

  provisioner "powershell" {
    inline = [
        "& $env:SystemRoot\\System32\\Sysprep\\Sysprep.exe /oobe /generalize /quiet /quit /unattend:\"C:\\Windows\\System32\\Sysprep\\unattend.xml\"",
        "while ($true) { $ImageState = Get-ItemProperty HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Setup\\State | Select-Object ImageState; if ($ImageState.ImageState -ne 'IMAGE_STATE_GENERALIZE_RESEAL_TO_OOBE') { Write-Output $ImageState.ImageState; Start-Sleep -Seconds 10 } else { break } }",
        "Stop-Computer -Force"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact  = false
      compression_level    = 9
      output               = "../output/${var.vm_name}_{{ .Provider }}.box"
      vagrantfile_template = "${path.root}/Vagrantfile"
    }
  }
}
