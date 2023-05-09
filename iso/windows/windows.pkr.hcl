// The Packer configuration
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

// Defines the local variables
locals {
  // Defines the local variables for iso selection
  iso_urls     = var.iso_url == null ? var.iso_urls : [var.iso_url]
  iso_checksum = var.iso_checksum == null ? "file:${var.iso_checksum_file}" : var.iso_checksum

  // Defines the local variables for VM and box naming
  build_date = formatdate("YYYYMMDDhhmm", timestamp())
  vm_name    = "windows-${var.vm_guest_os_version}-${var.vm_guest_os_edition}_${local.build_date}"

  // Defines the image selection local variables
  os_name        = var.vm_guest_os_name == "server" ? "Windows Server" : "Windows"
  os_edition     = var.vm_guest_os_name == "server" ? "SERVER${upper(var.vm_guest_os_edition)}" : title(var.vm_guest_os_edition)
  os_image_key   = var.vm_guest_os_image_index == null ? "/IMAGE/NAME" : "/IMAGE/INDEX"
  os_image_value = local.os_image_key == "/IMAGE/INDEX" ? var.vm_guest_os_image_index : "${local.os_name} ${var.vm_guest_os_version} ${local.os_edition}"

  // Defines other local variables
  vm_guest_input_locales = join(";", var.vm_guest_input_locales)
}

// Defines the builder configuration blocks
source "hyperv-iso" "windows" {
  headless = var.headless

  // Virtual Machine Settings
  vm_name     = local.vm_name
  cpus        = var.cpus
  memory      = var.memory
  disk_size   = var.disk_size
  switch_name = "Default Switch"
  generation  = 1

  // Removable Media Settings
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  cd_files = [
    "../../_common/windows/Enable-WinRM.ps1",
    "../../_common/windows/Start-Sysprep.ps1",
    "./scripts/PackerShutdown.bat"
  ]
  cd_content = {
    "autounattend.xml" = templatefile(
      "${path.root}/answer_files/autounattend.pkrtpl.hcl",
      {
        username      = var.admin_username,
        password      = var.admin_password,
        image_key     = local.os_image_key,
        image_value   = local.os_image_value,
        product_key   = var.vm_guest_product_key,
        timezone      = var.vm_guest_timezone,
        input_locale  = local.vm_guest_input_locales,
        system_locale = var.vm_guest_system_locale,
        ui_language   = var.vm_guest_ui_language,
        user_locale   = var.vm_guest_user_locale
      }
    ),
  }

  // Boot and Shutdown Settings
  boot_command     = ["<spacebar>"]
  shutdown_command = var.shutdown_command

  // Communicator Settings and Credentials
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_use_ntlm = true
  winrm_username = var.admin_username
  winrm_password = var.admin_password

  // Output Settings
  output_directory = "../../builds/VMs/hyperv"
}

source "virtualbox-iso" "windows" {
  headless = var.headless

  // Virtual Machine Settings
  vm_name              = local.vm_name
  guest_os_type        = "Windows10_64"
  cpus                 = var.cpus
  memory               = var.memory
  hard_drive_interface = "sata"
  disk_size            = var.disk_size
  firmware             = "bios"
  guest_additions_mode = "upload"
  guest_additions_path = "C:/Windows/Temp/GuestTools.iso"

  // Removable Media Settings
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  cd_files = [
    "../../_common/windows/Enable-WinRM.ps1",
    "../../_common/windows/Start-Sysprep.ps1",
    "./scripts/PackerShutdown.bat"
  ]
  cd_content = {
    "autounattend.xml" = templatefile(
      "${path.root}/answer_files/autounattend.pkrtpl.hcl",
      {
        username      = var.admin_username,
        password      = var.admin_password,
        image_key     = local.os_image_key,
        image_value   = local.os_image_value,
        product_key   = var.vm_guest_product_key,
        timezone      = var.vm_guest_timezone,
        input_locale  = local.vm_guest_input_locales,
        system_locale = var.vm_guest_system_locale,
        ui_language   = var.vm_guest_ui_language,
        user_locale   = var.vm_guest_user_locale
      }
    ),
  }

  // Boot and Shutdown Settings
  boot_command     = ["<spacebar>"]
  shutdown_command = var.shutdown_command

  // Communicator Settings and Credentials
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_use_ntlm = true
  winrm_username = var.admin_username
  winrm_password = var.admin_password

  // Output Settings
  output_directory = "../../builds/VMs/virtualbox"
}

// Defines the builders to run, provisioners, and post-processors
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
      "${path.root}/answer_files/unattend.pkrtpl.hcl",
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

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact  = false
      compression_level    = 9
      output               = "../../builds/boxes/${local.vm_name}_{{ .Provider }}.box"
      vagrantfile_template = "${path.root}/Vagrantfile"
    }
  }
}
