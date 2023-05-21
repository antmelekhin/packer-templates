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

  // Defines the local variables for VM and box naming
  build_date = formatdate("YYYYMMDDhhmm", timestamp())
  vm_name    = "${var.vm_guest_distr_name}-${var.vm_guest_distr_version}-${var.vm_guest_distr_edition}_${local.build_date}"
}

// Defines the builder configuration blocks
source "hyperv-iso" "linux" {
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
  http_content = local.http_content

  // Boot and Shutdown Settings
  boot_wait = "5s"
  boot_command = [
    "<esc><wait>",
    "auto ",
    "net.ifnames=0 ",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "<enter>"
  ]
  shutdown_command = var.shutdown_command

  // Communicator Settings and Credentials
  communicator = "ssh"
  ssh_username = var.admin_username
  ssh_password = var.admin_password
  ssh_timeout  = "30m"

  // Output Settings
  output_directory = "../../builds/VMs/virtualbox"
}

source "virtualbox-iso" "linux" {
  headless = var.headless

  // Virtual Machine Settings
  vm_name              = local.vm_name
  guest_os_type        = var.guest_os_type
  cpus                 = var.cpus
  memory               = var.memory
  hard_drive_interface = "sata"
  disk_size            = var.disk_size
  firmware             = "bios"
  guest_additions_mode = "upload"
  guest_additions_path = "/tmp/VBoxGuestAdditions.iso"

  // Removable Media Settings
  iso_urls     = local.iso_urls
  iso_checksum = local.iso_checksum
  http_content = local.http_content

  // Boot and Shutdown Settings
  boot_wait        = "5s"
  boot_command     = var.boot_command
  shutdown_command = var.shutdown_command

  // Communicator Settings and Credentials
  communicator = "ssh"
  ssh_username = var.admin_username
  ssh_password = var.admin_password
  ssh_timeout  = "30m"

  // Output Settings
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
