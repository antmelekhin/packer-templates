// The Packer configuration
packer {
  required_version = ">= 1.8.3"
  required_plugins {
    hyperv = {
      version = ">= v1.0.4"
      source  = "github.com/hashicorp/hyperv"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = ">= v1.0.3"
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
  iso_checksum = var.iso_checksum == null ? "file:${var.iso_checksum_file}" : var.iso_checksum
  iso_urls     = var.iso_url == null ? var.iso_urls : [var.iso_url]

  // Defines the local variables for VM and box naming
  build_date = formatdate("YYYYMMDDhhmm", timestamp())
  vm_name    = "${var.vm_guest_distr_name}-${var.vm_guest_distr_version}_${var.firmware}_${local.build_date}"

  // Defines the firmware local variables
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
  vm_name  = local.vm_name

  // Virtual Machine settings
  cpus      = var.cpus
  disk_size = var.disk_size
  memory    = var.memory

  // Hyper V specific settings
  enable_dynamic_memory = var.hyperv_enable_dynamic_memory
  generation            = var.firmware == "efi" ? 2 : 1
  switch_name           = var.hyperv_switch_name

  // Removable media settings
  http_content = local.http_content
  iso_checksum = local.iso_checksum
  iso_urls     = local.iso_urls

  // Boot and Shutdown settings
  boot_command     = local.boot_command
  boot_wait        = var.boot_wait
  shutdown_command = var.shutdown_command

  // Communicator settings and credentials
  communicator = "ssh"
  ssh_password = var.admin_password
  ssh_timeout  = "30m"
  ssh_username = var.admin_username

  // Output settings
  output_directory = "../../builds/VMs/virtualbox"
}

source "virtualbox-iso" "linux" {
  headless = var.headless
  vm_name  = local.vm_name

  // Virtual Machine settings
  cpus      = var.cpus
  disk_size = var.disk_size
  memory    = var.memory

  // VirtualBox specific settings
  firmware             = var.firmware
  guest_os_type        = var.vbox_guest_os_type
  hard_drive_interface = var.vbox_hard_drive_interface
  iso_interface        = var.vbox_iso_interface
  vboxmanage           = var.vboxmanage

  // Guest additions settings
  guest_additions_mode = "upload"
  guest_additions_path = "/tmp/VBoxGuestAdditions.iso"

  // Removable media settings
  http_content = local.http_content
  iso_checksum = local.iso_checksum
  iso_urls     = local.iso_urls

  // Boot and Shutdown settings
  boot_command     = local.boot_command
  boot_wait        = var.boot_wait
  shutdown_command = var.shutdown_command

  // Communicator settings and credentials
  communicator = "ssh"
  ssh_password = var.admin_password
  ssh_timeout  = "30m"
  ssh_username = var.admin_username

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
