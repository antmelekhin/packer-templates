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
  vm_name    = "windows-${var.vm_guest_os_version}-${var.vm_guest_os_edition}_${var.firmware}_${local.build_date}"

  // Defines the firmware local variables
  generation = var.firmware == "efi" ? 2 : 1

  // Defines the image selection local variables
  os_name        = var.vm_guest_os_name == "server" ? "Windows Server" : "Windows"
  os_edition     = var.vm_guest_os_name == "server" ? "SERVER${upper(var.vm_guest_os_edition)}" : title(var.vm_guest_os_edition)
  os_image_key   = var.vm_guest_os_image_index == null ? "/IMAGE/NAME" : "/IMAGE/INDEX"
  os_image_value = local.os_image_key == "/IMAGE/INDEX" ? var.vm_guest_os_image_index : "${local.os_name} ${var.vm_guest_os_version} ${local.os_edition}"

  // Defines other local variables
  vm_guest_input_locales = join(";", var.vm_guest_input_locales)

  // Defines the local variables for cd content
  cd_content = {
    "autounattend.xml" = templatefile(
      "${path.root}/answer_files/autounattend.pkrtpl.hcl",
      {
        firmware      = var.firmware,
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
    )
  }

  cd_files = [
    "../../_common/windows/Enable-WinRM.ps1",
    "../../_common/windows/Start-Sysprep.ps1",
    "./scripts/PackerShutdown.bat"
  ]
}

// Defines the builder configuration blocks
source "hyperv-iso" "windows" {
  headless = var.headless

  // Virtual Machine settings
  vm_name   = local.vm_name
  cpus      = var.cpus
  memory    = var.memory
  disk_size = var.disk_size

  // Hyper V specific settings
  switch_name           = var.switch_name
  generation            = local.generation
  enable_dynamic_memory = var.enable_dynamic_memory

  // Removable media settings
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  cd_content   = local.cd_content
  cd_files     = local.cd_files

  // Boot and Shutdown settings
  boot_wait        = var.boot_wait
  boot_command     = var.boot_command
  shutdown_command = var.shutdown_command

  // Communicator settings and credentials
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_use_ntlm = true
  winrm_username = var.admin_username
  winrm_password = var.admin_password

  // Output settings
  output_directory = "../../builds/VMs/hyperv"
}

source "virtualbox-iso" "windows" {
  headless = var.headless

  // Virtual Machine Settings
  vm_name   = local.vm_name
  cpus      = var.cpus
  memory    = var.memory
  disk_size = var.disk_size

  // VirtualBox specific settings
  guest_os_type        = var.guest_os_type
  firmware             = var.firmware
  iso_interface        = var.iso_interface
  hard_drive_interface = var.hard_drive_interface

  // Guest additions settings
  guest_additions_mode = "upload"
  guest_additions_path = "C:/Windows/Temp/GuestTools.iso"

  // Removable media settings
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  cd_content   = local.cd_content
  cd_files     = local.cd_files

  // Boot and Shutdown settings
  boot_wait        = var.boot_wait
  boot_command     = var.boot_command
  shutdown_command = var.shutdown_command

  // Communicator settings and credentials
  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_use_ntlm = true
  winrm_username = var.admin_username
  winrm_password = var.admin_password

  // Output settings
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
    sources = [
      "./scripts/setup_complete/",
      "../../_common/windows/Enable-WinRM.ps1"
    ]
    destination = "C:\\Windows\\Setup\\Scripts\\"
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
      keep_input_artifact = false
      compression_level   = 9
      output              = "../../builds/boxes/${local.vm_name}_{{ .Provider }}.box"
    }
  }
}
