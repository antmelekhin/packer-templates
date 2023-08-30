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
  vm_name    = "${var.vm_guest_distr_name}-${var.vm_guest_distr_version}-${var.vm_guest_distr_edition}_${var.firmware}_${local.build_date}"

  // Defines the firmware local variables
  generation   = var.firmware == "efi" ? 2 : 1
  boot_command = var.firmware == "efi" ? var.boot_command_efi : var.boot_command_bios

  // Defines the local variables for http content
  http_content = {
    "/preseed.cfg" = templatefile(
      "${path.root}/answer_files/${var.vm_guest_distr_name}/preseed.pkrtpl.hcl",
      {
        username          = var.admin_username,
        password          = var.admin_password,
        repository_mirror = var.vm_guest_repository_mirror,
        timezone          = var.vm_guest_timezone
      }
    )
  }
}

// Defines the builder configuration blocks
source "hyperv-iso" "linux" {
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
  http_content = local.http_content

  // Boot and Shutdown settings
  boot_wait        = var.boot_wait
  boot_command     = local.boot_command
  shutdown_command = var.shutdown_command

  // Communicator settings and credentials
  communicator = "ssh"
  ssh_username = var.admin_username
  ssh_password = var.admin_password
  ssh_timeout  = "30m"

  // Output settings
  output_directory = "../../builds/VMs/virtualbox"
}

source "virtualbox-iso" "linux" {
  headless = var.headless

  // Virtual Machine settings
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
  guest_additions_path = "/tmp/VBoxGuestAdditions.iso"

  // Removable media settings
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  http_content = local.http_content

  // Boot and Shutdown settings
  boot_wait        = "5s"
  boot_command     = local.boot_command
  shutdown_command = var.shutdown_command

  // Communicator settings and credentials
  communicator = "ssh"
  ssh_username = var.admin_username
  ssh_password = var.admin_password
  ssh_timeout  = "30m"

  // Output settings
  output_directory = "../../builds/VMs/virtualbox"
}

build {
  sources = [
    "source.hyperv-iso.linux",
    "source.virtualbox-iso.linux"
  ]

  provisioner "shell" {
    scripts = [
      "./scripts/install-guesttools.sh",
      "../../_common/linux/cleanup.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = false
      compression_level   = 9
      output              = "../../builds/boxes/${local.vm_name}_{{ .Provider }}.box"
    }
  }
}
