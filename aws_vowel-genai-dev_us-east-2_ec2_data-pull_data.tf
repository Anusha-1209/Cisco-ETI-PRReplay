

locals {
  name             = "motific-dev-use2-vms"
  region           = "us-east-2"
  ami_name_filters = {
    for ami_platform_flavor in var.ami_platform_flavors:
    "${ami_platform_flavor}" => {
      for ami_vm_arch in var.ami_vm_architectures:
        "${ami_vm_arch}" => {
          "name" = (
            # Equivalent of switch statement
            ami_platform_flavor == "CISCO_HARDENED_AL2" ? (
              ami_vm_arch == "x86_64" ? "CiscoHardened-AmazonLinux2-amd64*" :
              ami_vm_arch == "arm64"  ? "CiscoHardened-AmazonLinux2-arm64*" : null ):

            ami_platform_flavor == "AMAZON_LINUX_2" ? (
              ami_vm_arch == "x86_64" ? "al2023-ami*x86_64" :
              ami_vm_arch == "arm64"  ? "al2023-ami*arm64" : null ):

            ami_platform_flavor == "UBUNTU" ? (
              ami_vm_arch == "x86_64" ? "*ubuntu-jammy-22.04-amd64*"  :
              ami_vm_arch == "arm64"  ? "*ubuntu-jammy-22.04-arm64*"  : null ):

            ami_platform_flavor == "WINDOWS" ? (
              ami_vm_arch == "x86_64" ? "Windows_Server-2022-English-Full-Base-*" :
              ami_vm_arch == "arm64"  ? null  : null ):

            # Default to null
            null
          )
        }
    }
  }
  ami_owner_map = {
    for ami_platform_flavor in var.ami_platform_flavors:
    "${ami_platform_flavor}" => {
      "owner" = (
        # Equivalent of switch statement
        ami_platform_flavor == "CISCO_HARDENED_AL2" ? "849570812361" :

        ami_platform_flavor == "AMAZON_LINUX_2" ? "amazon" :

        ami_platform_flavor == "UBUNTU" ? "099720109477" :

        ami_platform_flavor == "WINDOWS" ? "amazon" :

        # Default to null
        null
      )
    }
  }

  ami_owner = var.custom_ami_owner != "" ? var.custom_ami_owner : local.ami_owner_map[var.ami_type]["owner"]
  ami_name_filter = var.custom_name_filer != "" ? var.custom_name_filer : local.ami_name_filters[var.ami_type][var.ami_arch]["name"]
}

data "aws_ami" "fetch_ami" {
  owners      = [local.ami_owner]
  most_recent = true
  filter {
    name   = "name"
    values = [local.ami_name_filter]
  }
}