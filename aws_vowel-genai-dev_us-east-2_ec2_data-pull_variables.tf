variable "ami_owner" {
  description = "The owner of the AMI"
  type        = string
  default     = "849570812361"
}

variable "ami_type" {
  type        = string
  description = <<EOF
   Type of Amazon Machine Image (AMI).
   Options:
      AMAZON_LINUX_2
      CISCO_HARDENED_AL2
      UBUNTU
      WINDOWS
  EOF
  default     = "CISCO_HARDENED_AL2"
  validation {
    condition     = contains(["AMAZON_LINUX_2", "WINDOWS", "CISCO_HARDENED_AL2", "UBUNTU"], var.ami_type)
    error_message = "Valid values for ami_type are `AMAZON_LINUX_2`, `WINDOWS`, `CISCO_HARDENED_AL2`, `UBUNTU`]."
  }
}

variable "ami_arch" {
  type        = string
  description = <<EOF
   Architecture of the AMI.
   Options:
      x86_64
      arm64
  EOF
  default     = "x86_64"
  validation {
    condition     = contains(["x86_64", "arm64"], var.ami_arch)
    error_message = "Valid values for ami_arch are `x86_64`, `arm64`."
  }
}

variable "ami_platform_flavors" {
  description = "List of AMI OS Flavors"
  type        = list(string)
  default     = ["AMAZON_LINUX_2", "CISCO_HARDENED_AL2", "UBUNTU", "WINDOWS"]
}

variable "ami_vm_architectures" {
  description = "List of supported architectures for the AMI"
  type        = list(string)
  default     = ["x86_64", "arm64"]
}

variable "custom_name_filer" {
  description = "Custom name filter for the AMI"
  type        = string
  default     = ""
}

variable "custom_ami_owner" {
  description = "Custom owner for the AMI"
  type        = string
  default     = "amazon"
}

variable "aws_account_name" {
  description = "The name of the AWS account"
  type        = string
  default     = "vowel-genai-dev"
}

variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-2"
}

################################################################################
# Variables CSDL Tagging
################################################################################
variable "cisco_mail_alias" {
  type        = string
  description = "Who to contact in case of any issues with/queries about a particular resource."
  default     = "eti-sre-admins@cisco.com"
}
variable "data_classification" {
  type        = string
  description = <<EOF
      Data Classification. Options:
      Cisco Restricted
      Cisco Highly Confidential
      Cisco Confidential
      Cisco Public
  EOF
  default     = "Cisco Confidential"
}
variable "data_taxonomy" {
  type        = string
  description = <<EOF
    Data Taxonomy. Options:
      Administrative Data
      Customer Data
      Entrusted Data
      Financing Data
      Support Data
      Telemetry Data
      Cisco Operations Data
      Cisco Strategic Data
      Human Resources Data
    Defaults to Cisco Operations Data.
  EOF
  default     = "Cisco Operations Data"
}
variable "environment" {
  type        = string
  description = <<EOF
   Environment. Options:
      Prod
      NonProd
      Sandbox
  EOF
  default     = "NonProd"
}
variable "resource_owner" {
  type        = string
  description = "Name of the Cisco BU or IT group who is responsible for the particular component."
  default     = "Outshift SRE"
}